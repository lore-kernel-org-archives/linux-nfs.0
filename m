From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: 2.4.20rc1 NFS V3 UDP client problems
Date: Thu, 14 Nov 2002 18:11:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021114181149.J20258@redhat.com>
References: <200211142033.gAEKXGHe010083@pookie.nersc.gov> <3DD42E26.A603AD36@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: canon@pookie.nersc.gov,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CT9O-0005AQ-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 15:11:54 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3DD42E26.A603AD36@amis.com>; from ewhiting@amis.com on Thu, Nov 14, 2002 at 04:13:42PM -0700
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

On Thu, Nov 14, 2002 at 04:13:42PM -0700, Eric Whiting wrote:
> I tried various MTU values headed gradually towards 9000. I found that a
> MTUs between 1500 and 7500 give me the expected performance. MTU values
> of anything much more than that causes problems given my setup.

Which NIC?  Some chipsets (like ns83820) only have an 8KB TX fifo and end 
up doing two passes over the data for larger packet sizes.  Also, running 
gige with a standard 32bit/33MHz bus is pretty close to the limits.

		-ben


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
