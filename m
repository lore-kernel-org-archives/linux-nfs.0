From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: SM_UNMON again -> kernel
Date: Mon, 21 Jul 2003 15:08:12 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0307211437200.32628-100000@kenzo.iwr.uni-heidelberg.de>
References: <20030720234558.GD1570@async.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Philippe Troin <phil@fifi.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eaP6-00065P-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Jul 2003 06:08:36 -0700
To: Christian Reis <kiko@async.com.br>
In-Reply-To: <20030720234558.GD1570@async.com.br>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sun, 20 Jul 2003, Christian Reis wrote:

> Oh, the masquerading has nothing to do with NFS.

It might, by error. I don't know if this is relevant as I seem to have 
lost track of this thread, but some keywords suggested me to write this 
message...

In some conditions when using iptables, UDP packets get wrongly re-routed
to the loopback interface. I've hit this some months ago with a RedHat 8.0
installation with the current (at that time) 2.4.18-something kernel; I
don't know if things changed in the meantime as I have rewritten the
iptables rules...

It seems that some forms of MASQ/NAT and marking packets (fwmark) don't 
play well together; this is mentioned towards the end of:

http://lartc.org/howto/lartc.netfilter.html

but there was not enough information about what exactly would happen.  So
when I did use them (MASQ and fwmark) together, some UDP packets which had
perfectly good IP headers (source: server-IP, dest: client-IP) would not
make it onto the wire towards the client, but could be captured with
tcpdump attached to "lo". I've searched the netfilter list and came up
with some hits, but there were only questions (so the problem is known!)  
and no solution.

Incidentally, I've noticed this packet loss when trying to mount a NFS
export. I don't remember exactly where the packet loss happened, but it
was always at the same point in the packet exchange (well, out of 5-6
tries that I've made, also with different client OSes) - most probably,
the final packet, the answer to the "MOUNT" request (sorry, fuzzy memory).
If I'd clear the iptables rules on the server, the same mount command
would succeed immediately.  After deleting all the rules that used
"fwmark" (but still using MASQ), everything worked fine.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
