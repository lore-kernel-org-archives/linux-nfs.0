Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462AbaKLNJL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Nov 2014 08:09:11 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sACD9B42025360
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 08:09:11 -0500
Received: from sh-el6.eng.rdu2.redhat.com (sh-el6.eng.rdu2.redhat.com [10.10.160.69])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sACD9AQ1020379
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 08:09:11 -0500
Date: Wed, 12 Nov 2014 08:09:10 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Re: mount default minor version behavior
In-Reply-To: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.11.1411120755430.20279@sh-el6.eng.rdu2.redhat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a quick summary of where the threads ended up:

 - Everyone agrees that if a specific minor version is specified, only
   that version should be attempted.

 - On the issue of minor version omission, the positions are:
   1) vers=4 means try 4.1, 4.0.
    Steve D
    Boaz
    Ben C

   2) vers=4 means try 4.0 only.
    Andros
    Anna
    Frank

   3) vers=4 means
   - if conf file defaultvers=4.1, try 4.1, 4.0.
   - else if defaultvers not set try 4.0 only.
    Trond

Anyone else want to weigh in? Trond's position can also count towards
the second position because we should consider the case where the config
file is not used or turned off in the build.  I think I could just add a
bit to the config file that switches between 1 and 2, something like
"usebestversion", which defaults to position 2.  That would allow a
distro to use the first behavior if they chose.

Ben


On Tue, 11 Nov 2014, Benjamin Coddington wrote:

> I will update mount.nfs so the default version is 4.1.  I have two quick
> questions on desired behavior:
>
>  o  Should mounts that do not specify a minor version be upgraded to the
> default minor version?
>
> For example, should 'mount -overs=4' turn into 'mount -overs4.1', if the
> current default is 4.1?
>
>
>  o If 'yes' to the above, should mount auto-retry decrementing minor
> versions if EPROTONOSUPPORT?
>
> For example, 'mount -overs=4' with a default of 4.2 would attempt: 4.2,
> then 4.1, then 4.0.
>
> Ben
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
