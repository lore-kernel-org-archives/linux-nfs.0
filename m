Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:40906 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758210Ab2C2DRl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 23:17:41 -0400
Message-ID: <4F73D44C.5090604@panasas.com>
Date: Wed, 28 Mar 2012 20:17:32 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for Linux 3.4...
References: <1332986348.19172.43.camel@lade.trondhjem.org>  <CA+55aFwVzhgsw005P3+BkLw_=noJwkQB3G=Q4GqhfLL1WyPHfg@mail.gmail.com>  <1332986928.19172.45.camel@lade.trondhjem.org>  <CA+55aFyQ0r5mN9=3DUVENCtdj8VMLRjiXTc5Xd4o+F=s9B8xMg@mail.gmail.com> <1332988097.19172.51.camel@lade.trondhjem.org>
In-Reply-To: <1332988097.19172.51.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/28/2012 07:28 PM, Myklebust, Trond wrote:

> On Wed, 2012-03-28 at 19:20 -0700, Linus Torvalds wrote:
>> On Wed, Mar 28, 2012 at 7:08 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>>>
>>> Sure thing... I wasn't aware of that semantic difference, but I'm quite
>>> happy to add it to my script...
>>
>> Thanks. And I noticed that it's supposed to be "tags/xyz" with a "s".
>>
>> Of course, you might as well just say "xyz" without mentioning the
>> tag[s] part at all, unless you have a branch with the same name and
>> want to explicitly disambiguate.
>>
>>                    Linus
> 
> The reason for adding the 'tags' label originally was precisely because
> I had an identically named branch, and I wanted to be able to send you
> the signed tag instead.
> 
> I've attached the script that I use to generate pull requests just in
> case someone else doesn't have their own version. It should be fairly
> obvious to modify...
> 



That's funny after my 20th time of running the command by hand and
doing a "man git-request-pull" because I can never remember the order
of things, and I always get the URL wrong 3 times, I decided I should write
a script, boom here it is sent on the mailing list.

Thank you Trond for sharing, here is a new user
Boaz
