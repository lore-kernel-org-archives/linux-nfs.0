From: Steffen Persvold <sp@scali.com>
Subject: Re: IRIX NFS server and Linux NFS client
Date: Thu, 11 Apr 2002 12:22:39 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0204111218440.30970-100000@elin.scali.no>
References: <Pine.LNX.4.30.0204110928530.28565-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <linux-kernel@vger.kernel.org>, <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vbj1-000666-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 03:22:44 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.30.0204110928530.28565-100000@elin.scali.no>
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

On Thu, 11 Apr 2002, Steffen Persvold wrote:

> Hi all,
>
> Is there any reason why my Linux NFS client (kernel 2.4.18
> nfs-utils-0.3.1-13.7.2.1 from RedHat 7.2) is not able to mount a directory
> exported from an IRIX server in NFSv3 (not sure which version of IRIX
> yet, if this is important I will find out). NFSv2 works fine, but if I
> try to force NFSv3 I get "Connection refused".
>
> I'll appreciate any help.
>

I forgot to mention that NFSv3 works when an IRIX client mounts the same
directory (i.e the directory shows up as "nfs" and not "nfs2" in the mount
table on the IRIX client).

Could it be that IRIX only supports NFSv3 with TCP and not UDP (I didn't
try TCP mounting on the Linux client) ?

Thanks,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
