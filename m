From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: Re: more info please
Date: Wed, 14 May 2003 10:32:27 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF2ABF12C0.C05D55EC-ON88256D26.00603AA1-88256D26.00605AEF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19G07n-00015S-00
	for <nfs@lists.sourceforge.net>; Wed, 14 May 2003 10:33:07 -0700
To: Matt Schillinger <mschilli@vss.fsi.com>
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





Statistics for the request reply cache:
      rc <hits> <misses> <nocache>

  Statistics for filehandle lookup:
      fh <stale> <total-lookups> <anon-lookups> <dir-not-in-dcache>
<nondir-not-in-dcache>

  Statistics for IO throughput:
      io <bytes-read> <bytes-written>

  time (seconds) when nfsd thread usage above thresholds and number of
times that all threads were in use:
      th <threads> <fullcnt> <10%-20%> <20%-30%> ... <90%-100%>

  Number of times that read-ahead entry was found that deep in the cache:
      ra <cache-size> <10% <20% <30% ... <100% <not-found>

  Socket statistics:
      net <netcnt> <netudpcnt> <nettcpcnt> <nettcpconn>
  where:
  <netcnt>
              Number of received requests
  <netudpcnt>
              Number of received datagrams on UDP sockets
  <nettcpcnt>
              Number of received packets on TCP sockets
  <nettcpconn>
              Number of accepted TCP connections


  RPC statistics:
      rpc <rpccnt> <total-bad> <rpcbadfmt> <rpcbadauth> <rpcbadclnt>
  where:
  <rpccnt>
              Number of RPC requests
  <total-bad>
              Total number of bad requests
  <rpcbadfmt>
              Bad format
  <rpcbadauth>
              Authentication failed
  <rpcbadclnt>
              N/A


  NFSv2 server procedure statistics:
      proc2 <nproc> <null> <getattr> <setattr> <root> <lookup> <readlink>
<read> <wrcache> <write> <create>
  <remove> <rename> <link> <symlink> <mkdir> <rmdir> <readdir> <fsstat>

  NFSv3 server procedure statistics:
      proc3 <nproc> <null> <getattr> <setattr> <lookup> <access> <readlink>
<read> <write> <create> <mkdir>
  <symlink> <mknod> <remove> <rmdir> <rename> <link> <readdir>
<readdirplus> <fsstat> <fsinfo> <pathconf>
  <commit>

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                          
                      Matt Schillinger                                                                                                    
                      <mschilli@vss.fsi.co        To:       nfs@lists.sourceforge.net                                                     
                      m>                          cc:                                                                                     
                      Sent by:                    Subject:  [NFS] more info please                                                        
                      nfs-admin@lists.sour                                                                                                
                      ceforge.net                                                                                                         
                                                                                                                                          
                                                                                                                                          
                      05/14/2003 10:24 AM                                                                                                 
                                                                                                                                          
                                                                                                                                          




I was wondering if there is documentation that details the meanings of
everything in /proc/net/rpc/nfsd

I know what th is, but I am curious what other information I can glean
from the file.

Thanks for your help,
--
Matt Schillinger

mschilli@vss.fsi.com





-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs





-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
