From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Tue, 23 Nov 2004 00:51:17 +0100
Message-ID: <41A27B75.4010309@int-evry.fr>
References: <482A3FA0050D21419C269D13989C61130435EBD2@lavender-fe.eng.netapp.com> <41A2594F.5000909@int-evry.fr> <Pine.WNT.4.61.0411222233280.1888@chalanches>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net, Joshua Baker-LePain <jlb17@duke.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWNxs-0003VY-10
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 15:51:24 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWNxq-0006tV-NH
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 15:51:23 -0800
To: Nicolas.Kowalski@imag.fr
In-Reply-To: <Pine.WNT.4.61.0411222233280.1888@chalanches>
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

Lucky guys !
real    1m33.781s
and
tar xzf ~/tmp/httpd-2.0.52.tar.gz
real 0m25.522s
these are the kind of values I am expecting ... ( although in the 25s 
case I see that you din't used -v option of tar, which does waist lot of 
time ...) . I still cannot explain myself why I need async mode on the 
export server to appraoch these kind of performances ... ?

Nicolas.Kowalski@imag.fr wrote:

> On Mon, 22 Nov 2004, jehan procaccia wrote:
>
>> Anyone is getting the same performance as me in server sync mode ?, 
>> if someone could just tar xvfz any recent httpd.tar.gz file (nearly 
>> 3000 source files) and let me know how it take on their nfs 
>> configuration ?
>
>
> Using a 2.4.27 Linux client, without any options for the NFS mount, on 
> a 100Mbps network, I get this when untarring httpd-2.0.52.tar.gz:
>
> real    1m33.781s
> user    0m0.610s
> sys     0m0.980s
>
> Server information:
>
> - Dual-Xeon 2.4Ghz, 1GB RAM, U160 73GB SCSI disks
>
> - Linux 2.4.27, XFS filesystems, quotas (user,group) on, no ACL, sync
>   exports.
>
> Regards.
>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
