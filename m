From: Nicolas.Kowalski@imag.fr
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 22:45:09 +0100
Message-ID: <Pine.WNT.4.61.0411222233280.1888@chalanches>
References: <482A3FA0050D21419C269D13989C61130435EBD2@lavender-fe.eng.netapp.com>
 <41A2594F.5000909@int-evry.fr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMK5-0007JC-He
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:06:13 -0800
Received: from imag.imag.fr ([129.88.30.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWMJo-00011x-P4
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:06:13 -0800
Received: from mail-veri.imag.fr (mail-veri.imag.fr [129.88.43.52])
	by imag.imag.fr (8.13.0/8.13.0) with ESMTP id iAMLjCgx019629
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 22:45:12 +0100 (CET)
Received: from kowalski-vpn.imag.fr ([129.88.61.129] helo=localhost)
	by mail-veri.imag.fr with esmtp (Exim 3.35 #1 (Debian))
	id 1CWLzj-0000NG-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 22:45:11 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <41A2594F.5000909@int-evry.fr>
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

On Mon, 22 Nov 2004, jehan procaccia wrote:

> Anyone is getting the same performance as me in server sync mode ?, if 
> someone could just tar xvfz any recent httpd.tar.gz file (nearly 3000 source 
> files) and let me know how it take on their nfs configuration ?

Using a 2.4.27 Linux client, without any options for the NFS mount, on a 
100Mbps network, I get this when untarring httpd-2.0.52.tar.gz:

real    1m33.781s
user    0m0.610s
sys     0m0.980s

Server information:

- Dual-Xeon 2.4Ghz, 1GB RAM, U160 73GB SCSI disks

- Linux 2.4.27, XFS filesystems, quotas (user,group) on, no ACL, sync
   exports.

Regards.

-- 
Nicolas



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
