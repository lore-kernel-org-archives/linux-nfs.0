From: Dwight Marzolf <dwight.marzolf@analog.com>
Subject: nfs over tcp for RedHat 8 kernel 2.4.20-20.8
Date: Thu, 28 Oct 2004 17:02:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41815E51.6010805@analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CNHPR-00076Y-It
	for nfs@lists.sourceforge.net; Thu, 28 Oct 2004 14:02:13 -0700
Received: from nwd2mail2.analog.com ([137.71.25.51])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CNHPQ-0003P7-M9
	for nfs@lists.sourceforge.net; Thu, 28 Oct 2004 14:02:13 -0700
Received: from nwd2mhb2.analog.com (nwd2mhb2.analog.com [137.71.6.12])
	by nwd2mail2.analog.com (8.12.10/8.12.10) with ESMTP id i9SL2DHB025413
	for <nfs@lists.sourceforge.net>; Thu, 28 Oct 2004 17:02:13 -0400
Received: from titania.adsdesign.analog.com (titania.adsdesign.analog.com [10.66.62.63])
	by nwd2mhb2.analog.com (8.9.3 (PHNE_28810+JAGae91741)/8.9.3) with ESMTP id RAA07327
	for <nfs@lists.sourceforge.net>; Thu, 28 Oct 2004 17:02:10 -0400 (EDT)
Received: from [10.66.22.21] (clapon [10.66.22.21])
	by titania.adsdesign.analog.com (8.10.2+Sun/8.10.2) with ESMTP id i9SL2BS17324
	for <nfs@lists.sourceforge.net>; Thu, 28 Oct 2004 17:02:11 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

Hi Everyone,

I am trying to get nfs over tcp working with kernel 2.4.20-20.8smp in 
RedHat8.  In searching the nfs email archives I found someone who had 
asked how to rebuild the redhat 2.4.20-30.9smp kernel to activate tcp 
for nfs.  The instructions were :

$ make mrproper oldconfig
 Edit the config file to turn on NFS over TCP
 $ make bzImage modules

I followed these instructions and the kernel rebuilt without errors.  I 
installed the rebuilt kernel and rebooted the machine into the new 
kernel.  But when I did a rpcinfo -p tcp still was not started for nfs.  
Only udp was started.  Is there something else I have to do once the 
kernel is rebuilt with tcp for nfs turned on in order to actually have 
the service started and visible in the rpcinfo -p command?

thanks,
dwight



-------------------------------------------------------
This Newsletter Sponsored by: Macrovision 
For reliable Linux application installations, use the industry's leading
setup authoring tool, InstallShield X. Learn more and evaluate 
today. http://clk.atdmt.com/MSI/go/ins0030000001msi/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
