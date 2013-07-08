Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.xtronics.com ([139.146.185.26]:37623 "EHLO
	smtp.xtronics.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3GHQPH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jul 2013 12:15:07 -0400
Message-ID: <51DADE1A.9040704@xtronics.com>
Date: Mon, 08 Jul 2013 10:43:22 -0500
From: Karl Schmidt <karl@xtronics.com>
MIME-Version: 1.0
To: Ben Hutchings <ben@decadent.org.uk>
CC: jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        714974@bugs.debian.org, Jonathan McDowell <noodles@earth.li>
Subject: Re: NFS 'readdir loop' error on JFS
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>
In-Reply-To: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/07/2013 08:13 PM, Ben Hutchings wrote:
> Jonathan McDowell and Karl Schmidt reported that when sharing a JFS
> filesystem through NFS and Samba, NFS clients can report 'readdir loop'
> and the directories in question then appear to have duplicate entries on
> the client system.
>
> This was seen with Linux 3.2 on the server and client.  The JFS
> directory code is basically unchanged since then, but NFS has changed
> somewhat.
>
> The original bug reports were:
> http://bugs.debian.org/685407#85
> http://bugs.debian.org/714974
>
> The log messages are:
> [593351.877678] NFS: directory fs/nfsd contains a readdir loop.Please contact your server vendor.  The file: .nfs3proc.o.cmda.com has duplicate cookie 73
> [593351.904689] NFS: directory fs/nfsd contains a readdir loop.Please contact your server vendor.  The file: .nfs3proc.o.cmda.com has duplicate cookie 73
> [280774.570555] NFS: directory //accounting contains a readdir loop.Please contact your server vendor.  The file: .~lock.credit.rtf1.rtf# has duplicate cookie 199
>
> Is this likely to be a problem with JFS, the NFS client or server?  Can
> anyone suggest how to investigate this further?
>
> Ben.

The experiment with NFS client on Windozs XP was bad - very poor performance. I'm told that it might 
work better in Windoze 7 - removed and back to samba.

For now, I am not having problems after commenting out this line in smb.conf

#strict locking = yes

Previously, I had already commented out :

#oplocks = no
#level2oplocks = no

But could still reproduce the problem.

I'm not sure it is fixed as there were time before when all worked well for some weeks before the 
errors turned.

Question: Is samba still using NLM protocol to lock files? ( I think NFS no longer uses that? )


,.,.,.
I've did find a different error during all this testing -included here as it might be related - 
perhaps due to the last nfs update.

in /etc/exports the server called malaysia we have:
/home/accounting 192.168.1.0/24(rw,sync,no_root_squash,no_all_squash)

fstab on a Debian wheezy client:
malaysia:/home/accounting    /mnt/accounting nfs   defaults,rsize=8192,wsize=8192,intr 0 0

/mnt# ll
total 112
drwxrwsrwx 16 nobody nogroup  4096 2013-07-08 08:00 accounting/

This is wrong..

I think this may have to do with a bug workaround where the installer added
27.0.1.1 to the /etc/hosts file ?

Then there is /etc/idmapd and /etc/defaults/nfs-common on the client that I didn't used to have to 
mess with?

It is also important to have the fqdn as the first name in /etc/hosts
hostname --fqdn is correct on both machines


I think this might have to do with a fix for CVE-2013-1923

The changes I made included adding

NEED_IDMAPD=yes

to /etc/defaults/nfs-common

And removing no_all_squash which is now the default.

Is NEED_IDMAPD=yes now needed as reverse lookups have been turned off?

The debian wiki needs updating to let people know they need to if this is really the case?

It has been a long night..



--------------------------------------------------------------------------------
Karl Schmidt                                  EMail Karl@xtronics.com
Transtronics, Inc.                              WEB http://secure.transtronics.com
3209 West 9th Street                             Ph (785) 841-3089
Lawrence, KS 66049                              FAX (785) 841-0434

Wrapping people up in the symbols of success when they are unearned, is very destructive. kps

--------------------------------------------------------------------------------
