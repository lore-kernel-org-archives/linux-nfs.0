Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36256 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934363AbcHJSZy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 14:25:54 -0400
MIME-Version: 1.0
In-Reply-To: <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com>
References: <20160810053947.GG21941@yexl-desktop> <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
 <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 10 Aug 2016 11:25:51 -0700
Message-ID: <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry ffff880027d7c540{i=1846f,n=0a}
 still in use (1) [unmount of btrfs vda]
To: Josef Bacik <jbacik@fb.com>
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 10, 2016 at 11:22 AM, Josef Bacik <jbacik@fb.com> wrote:
> On 08/10/2016 02:06 PM, Linus Torvalds wrote:
>>
>> More information in the original email on lkml.
>
> I'm not subscribed to lkml and for some reason I can't find the original
> email in any of the lkml/linux-nfs archives.  Could you forward more of the
> details?

Done.

             Linus
