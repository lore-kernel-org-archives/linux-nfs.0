From: Daryl Herzmann <akrherz@iastate.edu>
Subject: Re: RedHat 7.3 crashed NetApp?
Date: Fri, 17 May 2002 12:16:48 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.42.0205171214010.1202-100000@akrherz.agron.iastate.edu>
References: <20020517081125.A5553@lucon.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhub-1.iastate.edu ([129.186.140.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178lLW-000536-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 10:16:50 -0700
Received: from mailout-1.iastate.edu (mailout-1.iastate.edu [129.186.140.1])
	by mailhub-1.iastate.edu (8.9.3/8.9.3) with SMTP id MAA29435
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 12:16:47 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20020517081125.A5553@lucon.org>
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

Hi,

I reported the exact same thing with an IRIX server on Friday to this 
list.  I am glad that others are experiencing it too.  Using version 2 
made the troubles go away for me.

http://www.geocrawler.com/lists/3/SourceForge/789/75/8633160/

Time for a RH bugzilla entry or is there one?

Daryl

On Fri, 17 May 2002, H . J . Lu wrote:

>On Fri, May 17, 2002 at 08:14:37AM -0500, Cooke, Alan wrote:
>> While running the 2.4.18-4smp kernel (RedHat), and testing NFS3, our NetApp filer running OnTap 6.1.1R2 experienced massive incoming traffic from the Linux client in question. The Linux client required rebooting. We have been able to repeat this behavior, and are suspicious of the network driver on the Linux client which is using the eth0 driver. A
>> 
>
>I think it is the same as what happened to me. I had to reboot/unplug
>my Linux client before the whole NFS network went down. I am using Intel
>e100 driver on eepro100. But my Linux NFS severs have no problem with
>that client.
>
>
>H.J.
>
>

-- 
/**
 * Daryl Herzmann (akrherz@iastate.edu)
 * Program Assistant -- Iowa Environmental Mesonet
 * http://mesonet.agron.iastate.edu
 */




_______________________________________________________________

Hundreds of nodes, one monster rendering program.
Now that’s a super model! Visit http://clustering.foundries.sf.net/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
