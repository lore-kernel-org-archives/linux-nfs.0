From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: RE: debugging failed lock recovery
Date: Fri, 28 Jan 2005 10:27:25 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501281021130.7869@harp.ngdc.noaa.gov>
References: <482A3FA0050D21419C269D13989C61130853969F@lavender-fe.eng.netapp.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cud8d-0005GS-94
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 12:54:43 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cud86-0007MR-MQ
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 12:54:43 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CuZuH-0006zK-0P
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 09:27:41 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130853969F@lavender-fe.eng.netapp.com>
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

On Fri, 28 Jan 2005, Lever, Charles wrote:

> ara-
>
> the client must have a fully qualified nodename (uname -n) which matches
> the result of a DNS lookup, in order for lock recovery to work.
>
> the nodename is set in /etc/sysconfig/networking on red hat systems.

charles-

thanks for the lead!

yes.  they all have that and they are in dns.  however, our nfs runs on the
'backdoor': each client/server has two cards, one mated to

   client.domain

and one to

   client.b.domain

both are in dns.

*however* the output of uname -n is (of course) the frontdoor.  so it seems we
have a mismatch.  so uname -n *might* match the result of a dns lookup
depending on which interface is looked up and, i'm guessing, this will be the
backdoor interface and therefore fail.

anyone have ideas on what to do about this?  can nfs be run on a multihomed
server on an interface NOT named the same as 'uname -n'??

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
