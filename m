From: Fanying Jen <fanying@lillecorp.com>
Subject: NFS Crashes LTSP and NFS Servers and Corrupts Data! Need Help!
Date: Fri, 13 Jun 2003 21:21:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EEA7890.3010902@lillecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, ltsp-discuss@lists.sourceforge.net,
   redhat-list@redhat.com, jrosen@lillecorp.com
Return-path: <nfs-admin@lists.sourceforge.net>
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

I am a senior system administrator at Lille Corp whom provides thin 
client (LTSP or Linux Terminal Server Project) Linux solutions to the 
medical industry. We have a very serious problem with the reliability of 
NFS over both Fast Ethernet (100BaseT) and WANs including T1s point to 
point, and IPSEC VPNs where the other node is on business cable modem. 
The customer is a mid size medical assoicate with over three hundred 
staff members and two hundred terminals and PC, mostly Linux spread over 
three states.

There are two major problems with NFS. One is NFS crashing the entire 
three hundred person organization in one swoop and bringing it to a 
grinding halt in front of users and the patients (customers of the 
customer) which is not good particularily since Linux is branded to be 
more stable.

The other major problem is when NFS is not crashing systems, it looses 
data particularily with OpenOffice costing many man hours of work. In 
addition, even simple commands like "ls" have trouble displaying the 
entire directory and users sometimes get into a stale lock as well.

I will provide the network topology along with the system specs, 
configuration, and the software components.

Network Topology



                                       Local [LTSP]
                                               |
                         Fast Ethernet Segement|
Remote                                        |
[LTSP]---Cable Modem to T1 over IPSEC VPN---[NFS] Local
                                               | 
 
                                                          			     Point 
to Point T1|
                                               |
                                       Remote[LTSP]


Network Hardware - Total

1x Cisco Pix 515E (Local)
2x Cisco Pix 515R (Remote)
1x Cisco 3620 w/ 1x 10BaseT Ethernet and 3x Serial (T1) - Active (Local)
1x Dell PowerConnect 3024 24 port 10/100 managed switch (Local)
4x D-Link 10/100 Dumb Hub(Remote - Upgrading to Switch soon)
3x Cisco 2500 w/ 1x 10BaseT Ethernet and 1x Serial (T1) (Remote)
Misc Unmanaged Switches (Remote)

Network Hardware - Location

Local

1x Cisco Pix 515E (Local)
1x Cisco 3620 w/ 1x 10BaseT Ethernet and 3x Serial (T1) - Active (Local)
1x Dell PowerConnect 3024 24 port 10/100 managed switch (Local)

Remote A

1x Cisco 2500 w/ 1x 10BaseT Ethernet and 1x Serial (T1) (Remote)
2x D-Link 10/100 Dumb Hub(Remote - Upgrading to Switch soon)

Remote B

1x Cisco 2500 w/ 1x 10BaseT Ethernet and 1x Serial (T1) (Remote)
1x D-Link 10/100 Dumb Hub(Remote - Upgrading to Switch soon)

Remote C

1x Cisco 2500 w/ 1x 10BaseT Ethernet and 1x Serial (T1) (Remote)
1x D-Link 10/100 Dumb Hub(Remote - Upgrading to Switch soon)

Remote D

1x Cisco Pix 515R (Remote)
Unmanaged Dumb Switch

Remote E

1x Cisco Pix 515R (Remote)
Unmanaged Dumb Switch

Network Bandwidth

Local - 100BaseT
Remote A - T1 Full 1.544 Mbps
Remote B - T1 Fractional ~1.088 Mbps
Remote C - T1 Fractional ~1.118 Mbps
Remote D - Cable Modem ~768 kbps Mbps U/D
Remote E - Cable Modem ~512 kbps U/D

System Hardware - Total

2x Dell PowerEdge 1650 (Local)
	Dual Pentium III 1.4GHz,
	Dual 10/100/1000 NIC,
	2GB Memory
	36GB RAID 1 Ultra160 SCSI
5x IBM xSeries 205 (Remote)
	Single Pentium 4 2.66GHz
	Single 10/100/1000 NIC
	256MB Memory
	40GB Single IDE

The Dells serve as the NFS and LTSP servers on separate machines at the 
central location.

The IBMs serve as the LTSP for the remote sites and NFS mount the /home 
only directory from one of the Dell NFS servers.

Major Software Applications

RedHat 8.0 with all patches including kernel and glibc updated
OpenOffice 1.0.1 stock
ICEWM 1.2.6
Mozilla 1.3
Pine (Email)
RDesktop 1.1.0 (for Windows Terminal Server)
Konqueror 3.0.3 (for file management)

NFS Configuration (Server)

# /etc/exports
/home    *(rw,sync,no_root_squash) # Actual hostname removed

NFS Configuration (LTSP - All Local and Remote)

# /etc/fstab
nfsserver:/home  /home   nfs     defaults        0 0

All other configuration are defaults as per initial install.

NFS Problem 1 (Crashing)

The LTSP would create stale locks and eventually the LTSP server 
crashes. Furthermore, data is corrupted during the process.

NFS Problem 2 (Corruption)

This happens mostly in OpenOffice, more than once, data gets corrupted 
and when working with both Microsoft and native OpenOffice formats. On 
full local workstations where the files are save to the local disk, this 
does not happen. The office docuements are normally saved to an NFS 
filesystem.

NFS Problem 3 (Performance)

NFS is very slow over T1 and cable links but is just fine on the Local 
Fast Ethernet. It is slow enough to either knock people off or cause 
write errors. We are thinking the hubs play a major role and are 
replacing with high end managed switches. However we believe that there 
is more than meets the eye and the T1 also has something to do with.

Summary

Those are the problems and I give as much information as I possibly can. 
I would be appreciate if anyone can point us in the right direction. We 
commercial organization and our customer are also commercial and we all 
want Linux to success not only on the server but also on the desktop. 
This customer is one of the boldest I have seen in the embracing of 
Linux on the desktop and we want them to success to the fullest, 
therefore we are asking for your assistance so we can do what many 
people say you can't, make money with Linux!

Thank you and Sincerely,
Fanying Jen
Senior System Administration
Lille Corp.



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
