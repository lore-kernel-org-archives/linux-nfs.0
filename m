From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Thu, 20 Jan 2005 17:24:23 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501201709220.5142@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com> <16164.29864.268358.781865@gargle.gargle.HOWL>
 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
 <16871.11926.507904.373575@cse.unsw.edu.au>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net,
	Mark O Sleeper <Mark.O.Sleeper@noaa.gov>, thomas.r.carey@noaa.gov
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CrmbR-0002Ll-8q
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 16:24:41 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CrmbQ-0000vT-Om
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 16:24:41 -0800
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
>
> It would appear that some for of firewall is blocking access to bligh's
> statd from mussel, or that  bligh's statd is ignoring requests from mussel.
> I don't know which.

so i thought we had this figured - but it seems we do not.  here is what we
are (still) seeing

   client > obtain_lock

   server > cat /proc/locks  # shows client pid

   client > reboot

   client > obtain_lock # fails

   server > cat /proc/locks  # shows OLD client pid


so lock recovery is still not working.  our firewalls are as follows:

   server iptables:

     *filter
     :INPUT ACCEPT [0:0]
     :FORWARD ACCEPT [0:0]
     :OUTPUT ACCEPT [0:0]
     -N NFS
     -N ICMP
     -A INPUT -i lo -j ACCEPT
     -A INPUT -p icmp --icmp-type any -j ICMP
     -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
     -A INPUT -m state --state NEW -p tcp -m tcp --dport 22 -j SSH
     -A INPUT -m state --state NEW -p udp -m udp -j NFS
     -A INPUT -m state --state NEW -p tcp -m tcp --dport 2049 -j NFS
     -A INPUT -m state --state NEW -p tcp -m tcp --dport 111 -j NFS
     -A INPUT -m state --state NEW,INVALID -j REJECT --reject-with icmp-host-prohibited
     -A INPUT -j REJECT --reject-with icmp-host-prohibited
     -A ICMP -s 0/0 -j ACCEPT
     -A ICMP -j REJECT --reject-with icmp-host-prohibited
     -A NFS -s 10.1.0.0/16 -j ACCEPT
     -A NFS -j REJECT --reject-with icmp-host-prohibited
     -A SSH -s 10.1.0.0/16 -j ACCEPT
     -A SSH -j REJECT --reject-with icmp-host-prohibited
     COMMIT

   client iptables:

     filter
     :INPUT ACCEPT [0:0]
     :FORWARD ACCEPT [0:0]
     :OUTPUT ACCEPT [0:0]
     -N NFS
     -N ICMP
     -A INPUT -i lo -j ACCEPT
     -A INPUT -p tcp --dport 111 -j NFS
     -A INPUT -p udp --dport 111 -j NFS
     -A INPUT -p tcp --dport 32768 -j NFS
     -A INPUT -p udp --dport 32768 -j NFS
     -A INPUT -p tcp --dport 32769 -j NFS
     -A INPUT -p udp --dport 32769 -j NFS
     -A INPUT -s 10.1.0.0/16 -j ACCEPT
     -A INPUT -p icmp --icmp-type any -j ICMP
     -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
     -A INPUT -m state --state NEW -p tcp -m tcp --dport 22 -j SSH
     -A INPUT -m state --state NEW,INVALID -j REJECT --reject-with icmp-host-prohibited
     -A INPUT -j REJECT --reject-with icmp-host-prohibited
     -A ICMP -s 0/0 -j ACCEPT
     -A ICMP -j REJECT --reject-with icmp-host-prohibited
     -A SSH -s 10.1.0.0/16 -j ACCEPT
     -A SSH -j REJECT --reject-with icmp-host-prohibited
     -A NFS -s 10.1.0.0/16 -j ACCEPT
     -A NFS -j REJECT --reject-with icmp-host-prohibited
     COMMIT

if i understand correctly (and i realize this is off list) this should be
allowing everything between server and client.  we addeded the hole between
client and server to confirm that the firewall is not the problem.  we still,
however, see the problem.  btw - we a 'clearing' the lock in question by doing

   mv file_with_stale_lock foobar && mv foobar file_with_stale_lock

to give it a fresh inode.  this leaves the record in /proc/locks but allows us
to continue testing (we can again get the lock).  is there a better way to do
this that cleans out /proc/locks?

is anything obvious here?

some other bits of info:

   - both the server and client have two network cards (frontdoor/backdoor).
     nfs runs all on back door.  the holes we opened up were on both client and
     server for both frontdoor/backdoor.

   - all names live in dns  (server, server.b)

   - we are seeing this kind of thing (not only assoc with lock recovery) in
     /var/log/messages

     rpc.statd[1734]: Received erroneous SM_UNMON request from <client> for <server>

     i gather this is cause by some name confusion...

so.  where to go from here?  i can reproduce a 'dead' lock at will by simply
rebooting a client while holding a lock.  if i understand correctly the server
should be notified by the client of any locks it held before halting on the
subsequent reboot?  can this communication be logged verbosly somehow?  is
there an easier way to cause the notification of old locks to the server?
perhaps something like 'service nfslock restart' or is rebooting the only way?

sorry for false positive earlier.

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
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
