From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: Re: more info please
Date: Wed, 14 May 2003 15:30:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF92BB3471.44BC7B8A-ON88256D26.007B43F7-88256D26.007BA631@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Duc Vianney" <dvianney@us.ibm.com>,
   Matt Schillinger <mschilli@vss.fsi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19G4m9-0005RW-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 15:31:05 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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





Hi Trond,

Have the newer statistics counters been put in since 2.5.66?  On 2.5.66 all
I see are 'proc4 <nproc> <#null> <#compound>'.  It's good to know more
detail is being added; I really need to grab the latest bits.

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                       
                      Trond Myklebust                                                                                                  
                      <trond.myklebust@        To:       Duc Vianney/Austin/IBM@IBMUS                                                  
                      fys.uio.no>              cc:       Bruce Allan/Beaverton/IBM@IBMUS, Matt Schillinger <mschilli@vss.fsi.com>,     
                                                nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net                             
                      05/14/2003 02:56         Subject:  Re: [NFS] more info please                                                    
                      PM                                                                                                               
                                                                                                                                       
                                                                                                                                       




>>>>> " " == Duc Vianney <dvianney@us.ibm.com> writes:

     > How about NFSv4 statistics ??? ...

NFSv4 is a bit more difficult as there are only 2 RPC calls that are
defined: NULL and COMPOUND.

We're working around this to provide more detailed statistics, but for
the moment we're limited to the following:

  <NULL> <COMPOUND> <READ> <WRITE> <COMMIT> <OPEN> <OPEN_CONFIRM>
  <CLOSE> <SETATTR>

(where <COMPOUND> in the above list means: "all other operations")

Cheers,
  Trond





-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
