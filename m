From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4.20rc1 NFS V3 UDP client problems -- (not a problem now)
Date: Mon, 18 Nov 2002 11:59:47 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DD938A3.682C38E3@amis.com>
References: <200211142033.gAEKXGHe010083@pookie.nersc.gov> <3DD42E26.A603AD36@amis.com> <20021114181149.J20258@redhat.com> <3DD4305B.D439C6CD@amis.com> <20021114182320.K20258@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: canon@pookie.nersc.gov,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Dr66-00089M-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 10:58:14 -0800
To: Benjamin LaHaise <bcrl@redhat.com>
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

Ben, 

I found a 64Bit/66Mhz PCI bus and the jumbo frames are working fine.
Same 
kernel, same network cards, same Netapp 825 filer -- simply a different
motherboard.

Here are the NFS client read/write speeds for my setup.  The write
speeds appear to be somewhat limited by the netapps 825 disk/cpu speed.
I wish I had a netapps 9xx to test.

        TCP      UDP
READ    99MB/s  104MB/s
WRITE   36MB/s   49MB/s

UDP looks good with my current setup -- but with the gigE running jumbo
frames in the 32 bit PCI bus the UDP was sick on the reads -- 1MB/s.

Read testing is:
while(true);do mount blaa;dd if=path of=/dev/null bs=x count=y;umount
blaa;done
where bs/count equal a 500M file -- to use the netapps cache.

Write testing is:
dd if=/dev/zero of=file bs=1M

Network rates monitored using netapps syststat and the time results.

eric


Benjamin LaHaise wrote:
> I'd guess you're hitting the PCI bandwidth limitations then, as the larger
> packets permit greater throughput, which in turn drives up bus utilizations.
> If you've got any disk controllers on the same bus, that would definately
> explain the problem (or any other devices on the bus that are in use).
> 
>                 -ben


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
