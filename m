Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33176 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725927AbeICNva (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Sep 2018 09:51:30 -0400
Message-ID: <4aa0284e9f2d4b7994aa976926fd1a84493ee228.camel@kernel.org>
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
From: Jeff Layton <jlayton@kernel.org>
To: Harald Dunkel <harald.dunkel@aixigo.de>, linux-nfs@vger.kernel.org
Date: Mon, 03 Sep 2018 05:32:09 -0400
In-Reply-To: <a5a072db-8624-3f52-867e-c7a612df811f@aixigo.de>
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
         <b4c125d6-be59-6953-bfa7-8ada6f8daa01@aixigo.de>
         <30d4e07de5d976756857db77ddb17582897ae2bf.camel@kernel.org>
         <a5a072db-8624-3f52-867e-c7a612df811f@aixigo.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2018-09-03 at 10:34 +0200, Harald Dunkel wrote:
> Hi Jeff,
> 
> On 8/31/18 1:49 PM, Jeff Layton wrote:
> > 
> > Hi Harald,
> > 
> > Usually this means that the client and server have gotten out of sync
> > (possibly due to a server reboot), the client has tried to reclaim the
> > state it held before but that reclaim failed.
> > 
> 
> Is this supposed to happen on a server reboot? BTW, all Linux
> clients are run with a kernel command line like
> 
> 	nfs.nfs4_unique_id=6dcc70d4-7481-45b8-a3af-4fef4ea175d0
> 
> Each client has its own uuid, of course, hardwired at install time
> in the grub configuration.
> 

Yes, typically a server reboot will cause the client to reclaim its
state. If the server isn't restarting then you probably have a situation
where the client and server have gotten out of sync in some fashion, the
client is realizing it and attempting to reclaim its state.

One thing that could (potentially) cause this is a nfs4_unique_id
collision. You might want to survey your clients and ensure that there
aren't any.

> > Determining why that happened is is difficult from the info you have
> > here. Is your server being restarted regularly? What version of NFS are
> > you using to mount?
> > 
> 
> No, usually we have uptimes of several months for the NFServers.
> Its NFS4 (4.2):
> 
> # grep -i nfs /proc/mounts
> nfsd /proc/fs/nfsd nfsd rw,relatime 0 0
> nfs-data:/space/data /data nfs4 rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.19.96.122,local_lock=none,addr=172.19.96.205 0 0
> nfs-data:/space/home /home nfs4 rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.19.96.122,local_lock=none,addr=172.19.96.205 0 0
> 
> > v4.9 is pretty old at this point as well, you may want to try a newer
> > kernel on the client and see if it behaves better.
> > 
> 
> I am bound to the versions included in Debian 9. Currently it is
> kernel 4.9.110-3+deb9u4 on both client and server. Not to mention
> that we are also running hosts with Solaris 10 and 11, AIX 6.1 and
> 7.1, RedHat EL 5 to 7. NFS has to be rock-solid for our needs. Its
> difficult to move to a newer kernel for some trial and error.
> 

Pity -- a newer client would help rule out patches that have already
been fixed but that weren't backported to stable.

> Would you recommend to stick with NFS 4(.0) or NFS 3, avoiding the
> new code in NFS 4.{1,2}? Which NFS version in 4.9 or another LTS
> kernel suits best for production use?
> 

v4.1+ are fine (in general) for production, but there are always bugs.

I probably wouldn't make any changes until you have a clearer idea of
why your clients are going into reclaim. One idea might be to sniff NFS
traffic and see if you can suss out what's triggering that series of
events.

-- 
Jeff Layton <jlayton@kernel.org>
