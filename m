From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 14 Jan 2005 09:05:34 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501140852070.11608@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com> <16164.29864.268358.781865@gargle.gargle.HOWL>
 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
 <16871.11926.507904.373575@cse.unsw.edu.au>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpTxD-0006Xi-1m
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 08:05:39 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpTxB-0003id-K3
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 08:05:38 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16871.11926.507904.373575@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 14 Jan 2005, Neil Brown wrote:

> So bligh, the client, is running statd (the "status" service), but mussel
> can not talk to it.  This is a problem.

are you saying inbound rpc traffic flowing from server -> client MUST not be
blocked by the firewall and that it is NOT sufficient to allow ONLY inbound
rpc traffic client -> server?  sorry if this does not make sense - i'm a bit
out of my domain here...

> It would appear that some for of firewall is blocking access to bligh's
> statd from mussel, or that  bligh's statd is ignoring requests from mussel.
> I don't know which.

does that fit with this senario:

   - after reboot client/server have stale locks

   - oddly enough though, locking DOES work between client and server

the reason it works (even on the files with stale locks) is that i have built
in my own 'leasing' system to all the files i lock.  it basically does

   if get_lock
     refresher = forked_process_touching_file_at_interval
     at_exit{ release_lock_and_kill_refresher }
   else
     if lock_is_too_old
       mv file file.tmp && mv file.tmp file
     end
     retry
   end

although it's quite a bit smarter than that (for instance it uses an nfs safe
lockfile to ensure only one node could attempt lock recovery at a time).

this seems to work because it give the file a new inode and, therefore, the
stale lock is invalidated - though it obviously still exists.

whenever i attempt this procedure - which is admittedly pretty sketchy - i
send emails to myself detailing the file in question (stale lock), it's inode,
etc.  i have only ever seen this happen one time in 8 months and that was
during brutal testing that did a bunch of kill -9's on things.  that was
before yesterday - yesterday AALL my processes ran this procedure and this is
how i came to know that the system was fubar.

so, in summary, does your understanding indicate that it should be possible
for locks themselves to work but lock recovery to fail?  is that consistent
with some sort of firewall mis-config between server and client?  eg.  is
the traffic pattern required different for the two?

many thanks for the insight!

kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
