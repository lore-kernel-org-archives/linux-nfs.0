From: Robert Williamson <robbiew@us.ibm.com>
Subject: Re: 2.6.0-test3-bk10-final regression getting out of hand
Date: Tue, 4 Nov 2003 10:34:17 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF238208F6.B12938E7-ON85256DD4.005AB619-86256DD4.005AFA11@us.ibm.com>
References: <bo0n20$c3q$1@foehn.quickstep.oche.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AH48H-0005qB-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Nov 2003 08:34:17 -0800
Received: from e1.ny.us.ibm.com ([32.97.182.101])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AH48G-000474-P2
	for nfs@lists.sourceforge.net; Tue, 04 Nov 2003 08:34:16 -0800
In-Reply-To: <bo0n20$c3q$1@foehn.quickstep.oche.de>
To: Martin Spott <Martin.Spott@uni-duisburg.de>
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


I've been seeing NFS client problems as well....for quite sometime.  I too
thought it was the NFS code, however further testing took me to possible
problems with kernel memory code.

For more info on my problems checkout
http://bugme.osdl.org/show_bug.cgi?id=1097

-Robbie

Robert V. Williamson <robbiew@us.ibm.com>
Linux Test Project
IBM Linux Technology Center
Web: http://ltp.sourceforge.net
IRC: #ltp on freenode.irc.net
====================
"Only two things are infinite, the universe and human stupidity, and I'm
not sure about the former." -Albert Einstein


                                                                                                                                        
                      Martin Spott                                                                                                      
                      <Martin.Spott@uni-du        To:       nfs@lists.sourceforge.net                                                   
                      isburg.de>                  cc:                                                                                   
                      Sent by:                    Subject:  Re: [NFS] 2.6.0-test3-bk10-final regression getting out of hand             
                      nfs-admin@lists.sour                                                                                              
                      ceforge.net                                                                                                       
                                                                                                                                        
                                                                                                                                        
                      11/01/2003 10:29 AM                                                                                               
                                                                                                                                        




Voluspa <lista2@comhem.se> wrote:

> I'm experiencing a serious NFS regression since 2.6.0-test3-bk10-final
> (bk-set determined now). Since that, along the road to 2.6.0-test9,
> something has gotten completely out of hand.

I can second the experiences on heavy trouble with 2.6.0-test[8,9] as
NFS _client_ against 2.4.2[1,2] as a server. I didn't have different
servers for testing against but I pretty much _believe_ it's a client
issue.

I only sticked to 'official' 2.6.0-test patches and I'd like to
express, that beginning with 2.6.0-test8 the NFS client is absolutely
unsuable for me. Trying to copy (with 'cp') a file from a local
filesystem to the server over NFS.V2 or .V3 completely freezes _any_
NFS traffic with the same server.
Are there any significant changes to the NFS client I should back out
for the purpose of finding the 'bug' ?

Martin.
--
 Unix _IS_ user friendly - it's just selective about who its friends are !
--------------------------------------------------------------------------


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs





-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
