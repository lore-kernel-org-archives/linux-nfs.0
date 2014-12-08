Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51237 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750980AbaLHUpe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 15:45:34 -0500
Date: Mon, 8 Dec 2014 21:45:23 +0100
From: David =?iso-8859-1?Q?H=E4rdeman?= <david@hardeman.nu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] [RFC] nfs-utils: include headers from srcdir
Message-ID: <20141208204523.GA4819@hardeman.nu>
References: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu>
 <20141202124004.13015.5604.stgit@zeus.muc.hardeman.nu>
 <5485E82C.7030809@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <5485E82C.7030809@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 08, 2014 at 01:04:28PM -0500, Steve Dickson wrote:
>On 12/02/2014 07:40 AM, David Härdeman wrote:
>> Some of the headers in ./support/include get generated as part of the
>> build process (and end up in the build dir hierarchy) and some are
>> not (so they stay in the srcdir hierarchy).
>> 
>> That means the build breaks when using a separate build dir. I'm not sure
>> what the best way to make sure that -I$(top_srcdir)/support/include is
>> defined everywhere is. Consider this a basis for discussion rather than
>> a real patch. Someone with more autoconf-fu can surely come up with a better
>> solution.
>
>This one I didn't commit because it caused -I../../support/include to 
>defined twice. That path gets define ing  Makefile.in file in the 
>DEFAULT_INCLUDES macro. 

But only if $(top_srcdir) == $(top_builddir)

So, for example, if you do:

	cd nfs-utils
	mkdir tmp
	cd tmp
	../configure
	make

Then you'd have -I../../support/include and -I../../../support/include?

I think this is in line with:
http://www.gnu.org/software/automake/manual/html_node/Program-Variables.html

See the section on AM_CPPFLAGS...

An example from Gutenprint2:
AM_CPPFLAGS = -I$(top_srcdir)/include -I$(top_builddir)/include $(LOCAL_CPPFLAGS) $(GNUCFLAGS)

Though a more "complete" fix might be to either have a common include
file, or a non-recursive make :)

-- 
David Härdeman
