From: Donald Burns <DMB@reliance.co.uk>
Subject: RE: Problems with hard links in root NFS filesystem
Date: Fri, 2 Aug 2002 10:05:28 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F418066D6DFA5040A1169F0B39B7604A0DE23E@rg273.reliance.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rg134.reliance.co.uk ([62.254.170.185] ident=hidden-user)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aYNP-0006T0-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 02:05:39 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Dear All,

Many thanks to all those who responded so quickly -
one doesn't get support like this from Microsoft! My
coleagues were immensely impressed.

I added the option no_subtree_check to /etc/exports
and it has fixed all the problems described in my
original message.

Once again, I thank you.

Best Regards,

Donald.

Reliance Gear Company Ltd.
Rowley Mills
Penistone Road
Lepton
Huddersfield
England
HD8 0LE

Tel: +44 1484 601000				
fax: +44 1484 601001

http://www.reliance.co.uk 

THE INFORMATION IN THIS COMMUNICATION IS CONFIDENTIAL AND INTENDED ONLY FOR
THE USE OF THE ADDRESSEE.  DISCLOSURE, USE  OR COPYING OF THIS MESSAGE OR
ITS CONTENTS OTHER THAN BY THE ADDRESSEE IS PROHIBITED. IF YOU RECEIVE THIS
COMMUNICATION IN ERROR WE WOULD BE GRATEFUL IF YOU WOULD NOTIFY US
IMMEDIATELY AND DELETE ANY MATERIAL RECEIVED
NeilBrown



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
