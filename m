From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RedHat 7.3 crashed NetApp?
Date: Mon, 20 May 2002 07:19:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CF38@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 179o0R-00019F-00
	for <nfs@lists.sourceforge.net>; Mon, 20 May 2002 07:19:23 -0700
To: "'Benjamin LaHaise'" <bcrl@redhat.com>
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

ben-

were any patches applied to RH's 2.4.18 that touched the NFS client?
for example, were any of Trond's experimental patches applied?

thanks!

> [a few data points from the bugzilla entries]
> 
> On Fri, May 17, 2002 at 03:17:53PM -0700, Lever, Charles wrote:
> > i'm wondering what are the common elements here:
> > 
> > is the EEpro 100 ethernet card common to all clients
> > that exhibit this problem?
> 
> eepro, tulip, 3com have all shown problems with 2.4.18 (at least 
> serious performance issues).
> 
> >  NFSv3 over UDP?
> 
> Yes.  A number of people have now reported that forcing v2 operation 
> does not result in slow performance, whereas in the 2.4.9-ac12 based 
> kernel, v3 was fine.
> 
> 		-ben
> 

_______________________________________________________________
Hundreds of nodes, one monster rendering program.
Now that's a super model! Visit http://clustering.foundries.sf.net/

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
