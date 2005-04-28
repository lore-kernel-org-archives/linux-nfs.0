From: for_spam@gmx.de
Subject: export loopback mounted .iso`s failed
Date: Thu, 28 Apr 2005 20:27:20 +0200 (MEST)
Message-ID: <31436.1114712840@www27.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Hello !
I have a cdrom-server based on SuSE 9.1 (kernel 2.6.4) wich exports all it
cd-roms via nfs, too.
All CD-Roms (>50 so far) are loopback mounted on the server and exported to
the public as a single nfs-share "server:/cdroms"

this works perfectly so far - but now i realize that this doesn`t seem to
work under suse 9.3 (kernel 2.6.11) anymore, because of (kernel based)
nfsV4. I just don`t see the contents of the loopback mounted iso`s - just
empty shares.

how can i make this work with suse 9.3 and kernel based nfs ? I don`t want
to "switch back".

regards
Roland

ps:
please reply via cc to my mailadress - i`m not on this list.


-- 
+++ GMX - die erste Adresse für Mail, Message, More +++

10 GB Mailbox, 100 FreeSMS  http://www.gmx.net/de/go/topmail


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
