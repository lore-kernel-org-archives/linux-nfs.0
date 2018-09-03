Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:18194 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726196AbeICMxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Sep 2018 08:53:09 -0400
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
To: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
 <b4c125d6-be59-6953-bfa7-8ada6f8daa01@aixigo.de>
 <30d4e07de5d976756857db77ddb17582897ae2bf.camel@kernel.org>
From: Harald Dunkel <harald.dunkel@aixigo.de>
Message-ID: <a5a072db-8624-3f52-867e-c7a612df811f@aixigo.de>
Date: Mon, 3 Sep 2018 10:34:02 +0200
MIME-Version: 1.0
In-Reply-To: <30d4e07de5d976756857db77ddb17582897ae2bf.camel@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On 8/31/18 1:49 PM, Jeff Layton wrote:
> 
> Hi Harald,
> 
> Usually this means that the client and server have gotten out of sync
> (possibly due to a server reboot), the client has tried to reclaim the
> state it held before but that reclaim failed.
> 

Is this supposed to happen on a server reboot? BTW, all Linux
clients are run with a kernel command line like

	nfs.nfs4_unique_id=6dcc70d4-7481-45b8-a3af-4fef4ea175d0

Each client has its own uuid, of course, hardwired at install time
in the grub configuration.

> Determining why that happened is is difficult from the info you have
> here. Is your server being restarted regularly? What version of NFS are
> you using to mount?
> 

No, usually we have uptimes of several months for the NFServers.
Its NFS4 (4.2):

# grep -i nfs /proc/mounts
nfsd /proc/fs/nfsd nfsd rw,relatime 0 0
nfs-data:/space/data /data nfs4 rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.19.96.122,local_lock=none,addr=172.19.96.205 0 0
nfs-data:/space/home /home nfs4 rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.19.96.122,local_lock=none,addr=172.19.96.205 0 0

> v4.9 is pretty old at this point as well, you may want to try a newer
> kernel on the client and see if it behaves better.
> 

I am bound to the versions included in Debian 9. Currently it is
kernel 4.9.110-3+deb9u4 on both client and server. Not to mention
that we are also running hosts with Solaris 10 and 11, AIX 6.1 and
7.1, RedHat EL 5 to 7. NFS has to be rock-solid for our needs. Its
difficult to move to a newer kernel for some trial and error.

Would you recommend to stick with NFS 4(.0) or NFS 3, avoiding the
new code in NFS 4.{1,2}? Which NFS version in 4.9 or another LTS
kernel suits best for production use?


Regards
Harri
