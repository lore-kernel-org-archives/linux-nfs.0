From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] Take 2: Allow passing fine resolution timing options
 to mount
Date: Tue, 18 Aug 2009 20:49:09 -0400
Message-ID: <1250642949.7921.136.camel@heimdal.trondhjem.org>
References: <4A83628D.9000505@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
	jlayton@poochiereds.net, gud-OYTqUY/oFF8@public.gmane.org, juhlenko@akamai.com
To: Amit Gud <agud@akamai.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11100 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbZHSAtK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Aug 2009 20:49:10 -0400
In-Reply-To: <4A83628D.9000505@akamai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-12 at 17:47 -0700, Amit Gud wrote:
> This patch modifies parsing of mount options to allows passing units
> along with the options. Valid units are "s" for seconds and "ms" for
> milliseconds. When not specified, the unit defaults to seconds.
> 
> For example, "-o acdirmin=20ms" can be specified for 20 milliseconds,
> and "-o acdirmin=3s" or just "-o acdirmin=3" for 3 seconds.
> 
> This code also changes the display of options in /proc/<pid>/mountstats
> from seconds to milliseconds to reflect the accuracy.

This won't work. Suddenly the contents of /proc/self/mountinfo can no
longer be used as intended because acdirmin/max/... are being displayed
in milliseconds, whereas the default unit is in seconds.
Furthermore, you'll have rounding errors when converting backwards and
forwards into HZ, since the latter is usually > 1ms.

I agree with Neil. I think it would be better to use a 3 decimal fixed
point notation instead. Couldn't something like the following be made to
work?

static int nfs_parse_mstimeo(const char *str, unsigned long *res)
{
	unsigned int msecs;
	char *str2;

	msecs = (unsigned int)simple_strtoul(str, &str2, 10);
	msecs *= 1000;

	/* Check if we're being given fixed point decimal notation */
	if (*str2 == '.') {
		unsigned long m;
		size_t ndec = strlen(++str2);

		/* Disallow more than 1/1000 precision */
		if (ndec > 3)
			goto out_inval;
		if (strict_strtoul(str2, 10, &m))
			goto out_inval;
		switch (ndec) {
		case 1:
			m *= 10;
		case 2:
			m *= 10;
			break;
		}
		msecs += (unsigned int)m;
	} else if (*str2 != '\0' || str2 == str)
		goto out_inval;

	*res = msecs_to_jiffies(msecs);
	return 0;
out_inval:
	return -EINVAL;
}

static void nfs_display_mstimeo(struct seq_file *m, unsigned long val)
{
	unsigned int msec = jiffies_to_msecs(val);
	unsigned int rem = msec % 1000;

	seq_printf(m, "%u", msec / 1000);
	if (rem != 0)
		seq_printf(m, ".%.3u", rem);
}

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
