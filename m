From: "Mansell, Gary" <GRMansell@ricardo.com>
Subject: My messages file is swamped with errors: kernel: svc: bad direction 256, dropping request
Date: Wed, 5 Mar 2003 15:33:39 -0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D8091602C6011848B2FBEF5AE9797D8D4D22B3@bambi.stc.ricplc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [193.122.26.10] (helo=mtcemailsvr.mtc.ricplc.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18qatw-0008Sj-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Mar 2003 07:33:48 -0800
To: <nfs@lists.sourceforge.net>
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

My messages file is swamped (95% full) with these errors:

Feb 25 05:08:18 dfgsrv kernel: svc: bad direction 256, dropping request
Feb 25 05:08:58 dfgsrv last message repeated 6 times
Feb 25 05:10:02 dfgsrv last message repeated 11 times
Feb 25 05:11:02 dfgsrv last message repeated 10 times
Feb 25 05:12:02 dfgsrv last message repeated 10 times
Feb 25 05:13:02 dfgsrv last message repeated 10 times
Feb 25 05:14:02 dfgsrv last message repeated 10 times
Feb 25 05:15:01 dfgsrv last message repeated 10 times
Feb 25 05:16:01 dfgsrv last message repeated 10 times
Feb 25 05:17:01 dfgsrv last message repeated 10 times
Feb 25 05:18:01 dfgsrv last message repeated 10 times
Feb 25 05:19:01 dfgsrv last message repeated 10 times

They seem to start to occur when the nfs server subsystem starts up. My =
hypothesis is that one particular type of UNIX client is having trouble =
communicating properly with my server. I have had no reports back from =
the users of the NFS client workstations that things are not working =
correctly but I am getting thousands of messages swamping my messages =
file and this must be affecting performance at least on the server.

The machine is used an NFS and SMB fileserver to about 200 various UNIX =
and NT clients. It is a Dell PE2650 with 2x 2.4Ghz Zeons, 2Gb RAM, 2x =
18Gb system disks mirrored with the onboard RAID controller, 500Gb EMC =
RAID 5 storage attached via 2x Qlogic QLA2300 FCAL cards. There is also =
an HP 2/20 autoloader attached via an adaptec AHA3960 SCSI controller =
card. It is attached to the network via the two onboard Broadcom BCM5701 =
(groan) Gb network ports which are running in a bonded configuration.

The machine is running RH7.3 and kernel 2.4.18-18.7.xsmp and =
nfs-utils-0.3.3-5

I would appreciate it if someone could advise me what is wrong here - I =
can't see the wood for the trees :)


Gary Mansell
Senior Technical Analyst
IT Department
Ricardo Consulting Engineers Ltd.


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
