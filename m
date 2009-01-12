From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [basic] nfsd failing to start
Date: Mon, 12 Jan 2009 18:04:59 -0500
Message-ID: <81C79F78-751B-405C-BF61-9FFD903909A3@oracle.com>
References: <87zlhxy102.fsf@newsguy.com> <20090112172418.GC24322@fieldses.org> <54FED3E6-80D0-4D45-A295-1C2CE2F9DA56@oracle.com> <20090112222905.GI1834@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50913 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbZALXFQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2009 18:05:16 -0500
In-Reply-To: <20090112222905.GI1834@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 12, 2009, at 5:29 PM, J. Bruce Fields wrote:
> On Mon, Jan 12, 2009 at 05:14:15PM -0500, Chuck Lever wrote:
>> User land must be running a portmapper that supports rpcbind protocol
>> version 4.  Currently Linux's portmapper does not, which is why the
>> setting defaults to N.  Recent Fedora distributions have replaced the
>> portmap daemon with a port of Sun's rpcbind daemon, which does  
>> support
>> rpcbind version 4.  But most other distributions still use portmap.
>>
>> I was hoping not to clutter svc_register() with logic to determine  
>> which
>> is running, since it will add complexity with little value.  And
>> eventually (or, soon, hopefully) everyone will run the rpcbind  
>> port, and
>> that logic won't be needed at all.
>
> Other kernel developers and kernel testers are particularly valuable
> kernel users (by which I mean, valuable to us, since they do useful  
> work
> for us) who often use new kernels on old distributions.

>> In addition, rpcbind/libtirpc are still not entirely stable (API/ABI-
>> wise) so it may be better to leave this as a hard compile-time switch
>> until distributions are comfortable replacing portmap with rpcbind.
>
> Making it easy to switch between portmap and (newer) rpcbind daemons
> might make it easier to test and debug the newer code.
>
> None of this is in contradiction to what you've said--it's a
> tradeoff--but on balance I'd prefer the additional svc_register()  
> logic.

We really do want a hard switch to be able to turn this new feature off.

It's impossible for the kernel to detect which version of rpcbind is  
running.  Yes, it can tell if rpcbind v4 is supported or not, but what  
if some versions of rpcbind have a bug or exhibit some incompatible or  
undesirable behavior?  We have already required an incompatible rev of  
rpcbind once in the last six months because of bugs.

Because we have to support distributions like Ubuntu and Debian, which  
package basically what is in upstream without a lot of testing, we  
have to allow them to flip a switch to get the desired legacy  
behavior, while still permitting users who want to experiment to do so  
without a lot of trouble.  It's also in the best interest of our  
kernel community which you mention above.

Transitioning user space will be an effort for all distributions.   
This CONFIG switch was added so they could do that without worrying  
about their existing NFS implementation suddenly breaking after a  
kernel upgrade.  When/if it does misbehave, it is simply a matter of  
disabling one config option to restore order.

It would probably be easy to add some logic that detects a protocol  
version mismatch, and then prints a clearer error message.  That's  
what I had in mind to address bz 12256.  But this is never going to be  
perfect while user space IPv6 support is under development and in  
transition.

> --b.
>
>>
>>> --b.
>>>
>>>> CONFIG_RPCSEC_GSS_KRB5=m
>>>> # CONFIG_RPCSEC_GSS_SPKM3 is not set
>>>>
>>>> =====     *     =====     *     =====     *     =====
>>>>
>>>> # rpcinfo -p localhost
>>>>  program vers proto   port
>>>>   100000    2   tcp    111  portmapper
>>>>   100000    2   udp    111  portmapper
>>>>   100024    1   udp  34971  status
>>>>   100024    1   tcp  43460  status
>>>>   100005    1   udp  34365  mountd
>>>>   100005    1   tcp  44349  mountd
>>>>   100005    2   udp  34365  mountd
>>>>   100005    2   tcp  44349  mountd
>>>>   100005    3   udp  34365  mountd
>>>>   100005    3   tcp  44349  mountd
>>>>
>>>> =====     *     =====     *     =====     *     =====
>>>>
>>>> lsmod
>>>>
>>>> Module                  Size  Used by
>>>> nfs                   206772  0
>>>> nfsd                  185008  9
>>>> lockd                  55160  2 nfs,nfsd
>>>> nfs_acl                 2688  2 nfs,nfsd
>>>> auth_rpcgss            28548  1 nfsd
>>>> sunrpc                144584  9 nfs,nfsd,lockd,nfs_acl,auth_rpcgss
>>>> exportfs                3456  1 nfsd
>>>> fuse                   42268  0
>>>> usbhid                 13588  0
>>>> usbmouse                3712  0
>>>> usbkbd                  4992  0
>>>> floppy                 45348  0
>>>> pcspkr                  2176  0
>>>> i2c_i801                7952  0
>>>> r8169                  26500  0
>>>> i2c_core               17680  1 i2c_i801
>>>> mii                     4224  1 r8169
>>>> snd_intel8x0           25500  0
>>>> snd_ac97_codec         88352  1 snd_intel8x0
>>>> ehci_hcd               28684  0
>>>> uhci_hcd               18444  0
>>>> ac97_bus                1536  1 snd_ac97_codec
>>>> snd_pcm                48008  2 snd_intel8x0,snd_ac97_codec
>>>> snd_timer              15364  1 snd_pcm
>>>> snd                    34788  4
>>>> snd_intel8x0,snd_ac97_codec,snd_pcm,snd_timer
>>>> usbcore               104760  6
>>>> usbhid,usbmouse,usbkbd,ehci_hcd,uhci_hcd
>>>> snd_page_alloc          7304  2 snd_intel8x0,snd_pcm
>>>> intel_agp              22588  1
>>>> agpgart                25520  1 intel_agp
>>>> button                  5904  0
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>>> nfs"
>>>> in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



