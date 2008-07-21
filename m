From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol for mount.
Date: Mon, 21 Jul 2008 16:59:30 -0400
Message-ID: <86AF0E25-8463-40CC-B873-9E594983B2E2@oracle.com>
References: <18556.40594.897682.204554@notabene.brown> <76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com> <18559.53893.95829.499988@notabene.brown> <76bd70e30807190909n12b9f70an87ccb62198c3a7d@mail.gmail.com> <18562.57287.656749.540603@notabene.brown> <76bd70e30807201828t70d5b1d0m4c242c5c8864c3bb@mail.gmail.com> <18563.63821.501053.402741@notabene.brown> <18563.64191.468427.481673@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:22733 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbYGUU75 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2008 16:59:57 -0400
In-Reply-To: <18563.64191.468427.481673-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 20, 2008, at 10:55 PM, Neil Brown wrote:

> On Monday July 21, neilb@suse.de wrote:
>>
>> How about this?
>
> BTW, this and two other patches are in my git.
>
> The first is the sm-notify fix, as modified, and with another fix
> since Steve's last post.  There was a "return" which should have been
> inside and 'if' but was outside it.
>
> The second causes portmap lookup to use connected UDP ports.
>
> The third is the one I just posted.
>
> BTW Steve, it is a small thing, but when you apply patches to git you
> often seem to lose the subject line.  This causes the first line of
> the description to be using as the one line summary, which sometimes
> looks rather strange.

Yep, I noticed this too.  My patch descriptions usually make better  
sense with the short description left intact.

> The following changes since commit  
> ba8dd9533e647b70d6e46beed3dcd8d8036b02af:
>  Neil Brown (1):
>        If portmap is not listening on UDP (as apparently happens with
>
> are available in the git repository at:
>
>  git://neil.brown.name/nfs-utils/ for-steved
>
> Neil Brown (3):
>      sm-notify: perform DNS lookup in the background.
>      Use connected socket when probing portmap with UDP.
>      Check nfs options (vers/protocol) before trying mount.
>
> utils/mount/network.c   |   41 ++++++++++++++++++++++++ 
> +----------------
> utils/mount/network.h   |    2 +-
> utils/mount/nfsmount.c  |    2 +-
> utils/mount/stropts.c   |   18 +++++++-----------
> utils/statd/sm-notify.c |   39 +++++++++++++++++++++++++--------------
> 5 files changed, 59 insertions(+), 43 deletions(-)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



