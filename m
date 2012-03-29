Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:13112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207Ab2C2Eiw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2012 00:38:52 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for Linux 3.4...
Date: Thu, 29 Mar 2012 04:38:44 +0000
Message-ID: <3379B519-55A9-41F5-AFDA-EBB5BFF891B7@netapp.com>
References: <1332986348.19172.43.camel@lade.trondhjem.org>
 <CA+55aFwVzhgsw005P3+BkLw_=noJwkQB3G=Q4GqhfLL1WyPHfg@mail.gmail.com>
 <1332986928.19172.45.camel@lade.trondhjem.org>
 <CA+55aFyQ0r5mN9=3DUVENCtdj8VMLRjiXTc5Xd4o+F=s9B8xMg@mail.gmail.com>
 <1332988097.19172.51.camel@lade.trondhjem.org>
 <4F73D44C.5090604@panasas.com>
 <CA+55aFyHmQBXw3ik3qv81_3Zp+4r-VUt_TNBs-M19b6Zt7PDeQ@mail.gmail.com>
 <1332994124.30608.5.camel@lade.trondhjem.org>
 <CA+55aFwxkWpH1WyBnE1Lg9eRAfPsfcyoZev7-O9TGrPKTB1pOg@mail.gmail.com>
In-Reply-To: <CA+55aFwxkWpH1WyBnE1Lg9eRAfPsfcyoZev7-O9TGrPKTB1pOg@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 29, 2012, at 12:20 AM, Linus Torvalds wrote:

> On Wed, Mar 28, 2012 at 9:08 PM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
>> 
>> Maybe I'm running an older version of git (Fedora 16 latest update), but
>> when I do
> 
> Yeah, you need git 1.7.9 to get the tag content support.
> 
> With older git versions, spell out "tags/xyz" instead of just "xyz",
> and it will all work, but it still won't actually show the tag
> content.

When I do the tags/nfs-for-3.4-1, it still gives me that ..BRANCH.NOT.VERIFIED.. crap in the pull message.
Furthermore, it fails to actually push the tag to my upstream repository, meaning that I'm still prone to the 'Linus tried to pull, and the commit wasn't there" syndrome.

Could we perhaps set up a best practices webpage/wiki for this sort of thing with a pointer to that webpage in Documentations/SubmittingPatches? That way maintainers would have a source of information for which versions of 'git' that they need to use in order to provide you with the information that you want.

Cheers
  Trond