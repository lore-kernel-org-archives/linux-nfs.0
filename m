From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: Re: how many nfs  thread needed
Date: Fri, 25 Feb 2005 19:17:07 +0100
Message-ID: <421F6BA3.7050304@int-evry.fr>
References: <01e101c51b2a$07a027c0$bef5dc0a@corp.noxiane.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4k1p-0005Qp-Ei
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 10:17:29 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D4k1n-00042C-J4
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 10:17:29 -0800
To: DUPRE Julien <julien.dupre-renexter@renault.com>
In-Reply-To: <01e101c51b2a$07a027c0$bef5dc0a@corp.noxiane.net>
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

DUPRE Julien wrote:

> Hi,
>  
> i'm looking for tunning my NFS configuration on a RedHAt 7.3 ( my 
> client are in ES3)
> for increase my performance.
>  
> I reading some docs but i need help for chose a good value
>  
> balsa-b#  grep th /proc/net/rpc/nfsd 
> th 84 203258 22002.912 7932.515 4694.613 6721.031 4074.175 605.630 
> 396.916 376.582 501.927 2942.259
> balsa-b#
>  

you've already got 84 Threads and they all seem quite busy ! I'am not 
sure, but for me unless the last numbers above are near to zero second 
of use , you should increase the number of threads -> up to 128 in your 
case ? but will the server support it ? you seem to have many clients ?
have a look at:
http://marc.theaimsgroup.com/?l=linux-nfs&m=102824853219024&w=2
http://www.int-evry.fr/s2ia/user/procacci/Doc/NFS/nfs.html#htoc8

>
> I think i need to change my number of thread nfsd but how many ?
>  
>  
> Thanks in advance
>  
>  
>  
>  
>  
>  
>  
>  
>
>  
>
>------------------------------------------------------------------------
>
>-- Disclaimer ------------------------------------
>Ce message ainsi que les eventuelles pieces jointes constituent une correspondance privee et confidentielle a l'attention exclusive du destinataire designe ci-dessus. Si vous n'etes pas le destinataire du present message ou une personne susceptible de pouvoir le lui delivrer, il vous est signifie que toute divulgation, distribution ou copie de cette transmission est strictement interdite. Si vous avez recu ce message par erreur, nous vous remercions d'en informer l'expediteur par telephone ou de lui retourner le present message, puis d'effacer immediatement ce message de votre systeme.
>***
>This e-mail and any attachments is a confidential correspondence intended only for use of the individual or entity named above. If you are not the intended recipient or the agent responsible for delivering the message to the intended recipient, you are hereby notified that any disclosure, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender by phone or by replying this message, and then delete this message from your system.
>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
