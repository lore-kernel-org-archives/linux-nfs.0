From: Chris Rankin <rankincj@yahoo.com>
Subject: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Fri, 14 Apr 2006 14:42:20 +0100 (BST)
Message-ID: <20060414134220.25554.qmail@web52903.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: shemminger@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUOZA-0001vd-79
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 06:42:28 -0700
Received: from web52903.mail.yahoo.com ([206.190.49.13])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FUOZ8-0001Q1-Hz
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 06:42:28 -0700
To: bridge@osdl.org
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

Hi,

I have 2 servers which are connected to a gateway machine. The gateway an=
d one server are running
Linux 2.6.16.2, while the third machine is running 2.6.16.5. The two ethe=
rnet ports on the gateway
which are connected to the servers are combined into a single ethernet br=
idge device.

Ever since 2.6.16, I have noticed that I can no longer cross-mount the tw=
o servers' /home
directories via UDP NFS. Which is to say that the mount command succeeds,=
 but that trying to
access the filesystem makes the process hang and the "NFS server not resp=
onding" message to appear
in the console log. This is true regardless of which machine is the NFS s=
erver and which is the
NFS client.

It all works fine if I use TCP NFS instead.

Also, UDP NFS works OK between any server and the gateway itself, so it o=
nly goes wrong when UDP
NFS traffic is forwarded across the bridge. (I have not changed my firewa=
ll rules, which just tell
the gateway to forward all traffic coming in from the bridge device anywa=
y.)

Can anyone reproduce this, please? I obviously have a workaround (using T=
CP instead of UDP) but it
sounds like there's a bug somewhere.

Cheers,
Chris



	=09
___________________________________________________________=20
Switch an email account to Yahoo! Mail, you could win FIFA World Cup tick=
ets. http://uk.mail.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
