From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4.20rc1 NFS V3 UDP client problems
Date: Thu, 14 Nov 2002 16:13:42 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DD42E26.A603AD36@amis.com>
References: <200211142033.gAEKXGHe010083@pookie.nersc.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CT3G-0003wP-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 15:05:34 -0800
To: canon@pookie.nersc.gov
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

I tried various MTU values headed gradually towards 9000. I found that a
MTUs between 1500 and 7500 give me the expected performance. MTU values
of anything much more than that causes problems given my setup.

eric


canon@pookie.nersc.gov wrote:
> 
> We had to set our MTUs to 8960 for things to work.
> We've never followed through to see what the issue
> was though.
> 
> We are using SysKonnect cards and 2.4.18 kernel.  Note,
> we haven't recently verified that the problem still
> exists.
> 
> --Shane


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
