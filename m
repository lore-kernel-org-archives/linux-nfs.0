From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: RedHat 7.3 crashed NetApp?
Date: Fri, 17 May 2002 20:17:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020517201759.C16999@redhat.com>
References: <6440EA1A6AA1D5118C6900902745938E50CF34@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178rv7-000596-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 17:18:02 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E50CF34@black.eng.netapp.com>; from Charles.Lever@netapp.com on Fri, May 17, 2002 at 03:17:53PM -0700
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

[a few data points from the bugzilla entries]

On Fri, May 17, 2002 at 03:17:53PM -0700, Lever, Charles wrote:
> i'm wondering what are the common elements here:
> 
> is the EEpro 100 ethernet card common to all clients
> that exhibit this problem?

eepro, tulip, 3com have all shown problems with 2.4.18 (at least 
serious performance issues).

>  NFSv3 over UDP?

Yes.  A number of people have now reported that forcing v2 operation 
does not result in slow performance, whereas in the 2.4.9-ac12 based 
kernel, v3 was fine.

		-ben

_______________________________________________________________

Hundreds of nodes, one monster rendering program.
Now that’s a super model! Visit http://clustering.foundries.sf.net/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
