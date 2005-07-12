From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: Performance Difference Between Linux NFS Server and Netapp
Date: Tue, 12 Jul 2005 11:24:50 -0500
Message-ID: <EXCHG2003ZbLAX3cf3e00000023@EXCHG2003.microtech-ks.com>
References: <42D2F8F9.4010304@plasmabat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsNX8-00012e-3L
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:22:58 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsNX5-0008A6-Ib
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:22:58 -0700
To: "'Hugh Caley'" <hcaley@plasmabat.com>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <42D2F8F9.4010304@plasmabat.com>
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


Locally disk cache will cause the results to be junk,
locally the cache will be used, with NFS the cache
will not be used for writes.

With Suse 9 Enterprise and a disk subsystem that will
sustain rates of 125MiB/second I can get write rates of
95MiB/second and read rates of 115MiB/second, this is
with sustained over 12 minutes of writes.

2000mbit/second is a rate that no ide disk subsystem
will obtain, so double check your local performance, 
if it is fast single disk it will get 50mb/second, if
you are using a built-in ata controller, with all channels
having fast disks you won't be able exceed 90mb/second
no matter what disk you use or how many or how you stripe
them, as the build-in mb controllers are not the best, 
and this is on the  more expensive dual-cpu mbs, it may
be worse on the single cpu machines.

You will need to use a test larger than the ram size of 
the machine to get a realistic rate, at least 2x, and
probably 4x, and maybe both just to see how things fall
over.

                         Roger

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Hugh Caley
> Sent: Monday, July 11, 2005 5:56 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] Performance Difference Between Linux NFS 
> Server and Netapp
> 
> I've been doing a little limited benchmarking of NFS 
> performance, and doing a comparison between Linux NFS servers 
> and a Netapp.  All tests done over gigabit, clients are Linux 
> (i386 and Opteron), OS is Fedora Core 2, kernel is 
> 2.6.10-1.771_FC2smp, filesystem is Reiser.  I basically copy a
> 205
> megabyte file to the server three times and average the 
> results.  Sure, limited, but it seems to have real world 
> relevance here.
> 
> The difference in performance is kind of startling.  I had 
> originally put the Linux-based servers (with a Nexsan 
> Atabeast backend) in as a replacement for an older EMC 
> Celerra and a few older Suns.  On both the Suns and Celerra I 
> would see single-client performance topping out at between 
> 120 and 150 megabits per second.
> 
> The Linux setup (Supermicro Dual 2.6 Ghz Xeons with 4 
> gigabytes of RAM, recently boosted to 8 gigabytes of RAM) 
> regularly returns about 300 megabits per second.  Given the 
> difference in price between the Linux boxes and the Celerra, 
> everyone's pretty happy ;)
> 
> However, recently I've been trying the same testing between 
> Linux clients and a Netapp, and can achieve between 500 and 
> 600 megabits per second!  Darned impressive.
> 
> I realize that the disk subsystem of the Netapp is going to 
> stomp on my Atabeast, but neither 300 nor 600 megabits is 
> anywhere near the speed I can get if I run the same test 
> locally on the Linux server boxes, which can regularly top 
> 2000 megabits per second, so I really don't think that the 
> differences in disk architecture should make this much difference.
> 
> I guess my question is, are my Linux NFS servers seriously 
> underperforming?  Could I expect to achieve better?  I 
> realize that my "benchmark" is pretty limited, but the 
> difference is pretty big.  Since the same client on all the 
> Linux boxen gets these results, I'm guessing that the client 
> end has little to do with it.
> 
> How does Netapp do it?  Don't suppose they'd tell me ...
> 
> Hugh
> 
> --
> Hugh Caley | Unix Systems Administrator | CIS AFFYMETRIX INC. 
> | 6550 Vallejo St. Ste 100 | Emeryville, CA 94608
> Tel: 510-428-8537 | Hugh_Caley@affymetrix.com
> 
> --
> "Brain-eating mutants are bad for business" - Battle Angel 
> Batmensch <hcaley@plasmabat.com>
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by the 'Do More With Dual!' 
> webinar happening
> July 14 at 8am PDT/11am EDT. We invite you to explore the 
> latest in dual
> core and dual graphics technology at this free one hour event 
> hosted by HP, 
> AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
