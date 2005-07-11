From: Hugh Caley <hcaley@plasmabat.com>
Subject: Performance Difference Between Linux NFS Server and Netapp
Date: Mon, 11 Jul 2005 15:55:53 -0700
Message-ID: <42D2F8F9.4010304@plasmabat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds7CU-0003GB-TL
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 15:56:34 -0700
Received: from scfw.affymetrix.com ([12.22.48.133] helo=msex02.affymetrix.com)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.44)
	id 1Ds7Bz-0005fS-RQ
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 15:56:35 -0700
To: nfs@lists.sourceforge.net
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

I've been doing a little limited benchmarking of NFS performance, and
doing a comparison between Linux NFS servers and a Netapp.  All tests
done over gigabit, clients are Linux (i386 and Opteron), OS is Fedora
Core 2,
kernel is 2.6.10-1.771_FC2smp, filesystem is Reiser.  I basically copy a
205
megabyte file to the server three times and average the results.  Sure,
limited,
but it seems to have real world relevance here.

The difference in performance is kind of startling.  I had originally
put the Linux-based servers (with a Nexsan Atabeast backend) in as a
replacement for an older EMC Celerra and a few older Suns.  On both the
Suns and Celerra I would see single-client performance topping out at
between 120 and 150 megabits per second.

The Linux setup (Supermicro Dual 2.6 Ghz Xeons with 4 gigabytes of RAM,
recently boosted to 8 gigabytes of RAM) regularly returns about 300
megabits per second.  Given the difference in price between the Linux
boxes and the Celerra, everyone's pretty happy ;)

However, recently I've been trying the same testing between Linux
clients and a Netapp, and can achieve between 500 and 600 megabits per
second!  Darned impressive.

I realize that the disk subsystem of the Netapp is going to stomp on my
Atabeast, but neither 300 nor 600 megabits is anywhere near the speed I
can get if I run the same test locally on the Linux server boxes, which
can regularly top 2000 megabits per second, so I really don't think that
the differences in disk architecture should make this much difference.

I guess my question is, are my Linux NFS servers seriously
underperforming?  Could I expect to achieve better?  I realize that my
"benchmark" is pretty limited, but the difference is pretty big.  Since
the same client
on all the Linux boxen gets these results, I'm guessing that the client end
has little to do with it.

How does Netapp do it?  Don't suppose they'd tell me ...

Hugh

--
Hugh Caley | Unix Systems Administrator | CIS
AFFYMETRIX INC. | 6550 Vallejo St. Ste 100 | Emeryville, CA 94608
Tel: 510-428-8537 | Hugh_Caley@affymetrix.com

-- 
"Brain-eating mutants are bad for business" - Battle Angel
Batmensch <hcaley@plasmabat.com>



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
