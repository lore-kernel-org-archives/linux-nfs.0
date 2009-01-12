From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [basic] nfsd failing to start
Date: Mon, 12 Jan 2009 17:29:05 -0500
Message-ID: <20090112222905.GI1834@fieldses.org>
References: <87zlhxy102.fsf@newsguy.com> <20090112172418.GC24322@fieldses.org> <54FED3E6-80D0-4D45-A295-1C2CE2F9DA56@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harry P <reader-kFrNdAxtuftBDgjK7y7TUQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53953 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758830AbZALW3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 17:29:07 -0500
In-Reply-To: <54FED3E6-80D0-4D45-A295-1C2CE2F9DA56@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2009 at 05:14:15PM -0500, Chuck Lever wrote:
> User land must be running a portmapper that supports rpcbind protocol  
> version 4.  Currently Linux's portmapper does not, which is why the  
> setting defaults to N.  Recent Fedora distributions have replaced the  
> portmap daemon with a port of Sun's rpcbind daemon, which does support  
> rpcbind version 4.  But most other distributions still use portmap.
>
> I was hoping not to clutter svc_register() with logic to determine which 
> is running, since it will add complexity with little value.  And  
> eventually (or, soon, hopefully) everyone will run the rpcbind port, and 
> that logic won't be needed at all.

Other kernel developers and kernel testers are particularly valuable
kernel users (by which I mean, valuable to us, since they do useful work
for us) who often use new kernels on old distributions.

> In addition, rpcbind/libtirpc are still not entirely stable (API/ABI- 
> wise) so it may be better to leave this as a hard compile-time switch  
> until distributions are comfortable replacing portmap with rpcbind.

Making it easy to switch between portmap and (newer) rpcbind daemons
might make it easier to test and debug the newer code.

None of this is in contradiction to what you've said--it's a
tradeoff--but on balance I'd prefer the additional svc_register() logic.

--b.

>
>> --b.
>>
>>>  CONFIG_RPCSEC_GSS_KRB5=m
>>>  # CONFIG_RPCSEC_GSS_SPKM3 is not set
>>>
>>> =====     *     =====     *     =====     *     =====
>>>
>>> # rpcinfo -p localhost
>>>   program vers proto   port
>>>    100000    2   tcp    111  portmapper
>>>    100000    2   udp    111  portmapper
>>>    100024    1   udp  34971  status
>>>    100024    1   tcp  43460  status
>>>    100005    1   udp  34365  mountd
>>>    100005    1   tcp  44349  mountd
>>>    100005    2   udp  34365  mountd
>>>    100005    2   tcp  44349  mountd
>>>    100005    3   udp  34365  mountd
>>>    100005    3   tcp  44349  mountd
>>>
>>> =====     *     =====     *     =====     *     =====
>>>
>>> lsmod
>>>
>>> Module                  Size  Used by
>>> nfs                   206772  0
>>> nfsd                  185008  9
>>> lockd                  55160  2 nfs,nfsd
>>> nfs_acl                 2688  2 nfs,nfsd
>>> auth_rpcgss            28548  1 nfsd
>>> sunrpc                144584  9 nfs,nfsd,lockd,nfs_acl,auth_rpcgss
>>> exportfs                3456  1 nfsd
>>> fuse                   42268  0
>>> usbhid                 13588  0
>>> usbmouse                3712  0
>>> usbkbd                  4992  0
>>> floppy                 45348  0
>>> pcspkr                  2176  0
>>> i2c_i801                7952  0
>>> r8169                  26500  0
>>> i2c_core               17680  1 i2c_i801
>>> mii                     4224  1 r8169
>>> snd_intel8x0           25500  0
>>> snd_ac97_codec         88352  1 snd_intel8x0
>>> ehci_hcd               28684  0
>>> uhci_hcd               18444  0
>>> ac97_bus                1536  1 snd_ac97_codec
>>> snd_pcm                48008  2 snd_intel8x0,snd_ac97_codec
>>> snd_timer              15364  1 snd_pcm
>>> snd                    34788  4  
>>> snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer
>>> usbcore               104760  6  
>>> usbhid,usbmouse,usbkbd,ehci_hcd,uhci_hcd
>>> snd_page_alloc          7304  2 snd_intel8x0,snd_pcm
>>> intel_agp              22588  1
>>> agpgart                25520  1 intel_agp
>>> button                  5904  0
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
>>> in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
