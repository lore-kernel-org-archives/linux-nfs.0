From: Vladimir Vuksan <croatia@firstlinux.net>
Subject: RE: RedHat 7.3 crashed NetApp?
Date: Tue, 21 May 2002 14:53:56 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020521215356.9B5522756@sitemail.everyone.net>
Reply-To: croatia@firstlinux.net
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sitemail3.everyone.net ([216.200.145.37] helo=omta03.mta.everyone.net)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17AHZt-0002oI-00
	for <nfs@lists.sourceforge.net>; Tue, 21 May 2002 14:53:57 -0700
Received: from sitemail.everyone.net (dsnat [216.200.145.62])
	by omta03.mta.everyone.net (Postfix) with ESMTP id D18CA48B37
	for <nfs@lists.sourceforge.net>; Tue, 21 May 2002 14:53:56 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

We have had a similar problem with NetApp F720 where couple times a day NetApp would stop responding. On one occassion we had an occurence where a single box was trying to write out a 2 GB core dump file to the NetApp which completely hosed it down. Even without misbehaving problems we had issues with it. We had a script from NetApp that was continuously doing sysstat, nfsstat but there were no indications on what was going on. This is all on a network of RedHat 7.2 clients with 2.4.9-31 RedHat stock kernel. What saved us was switching to NFS over TCP. I am not very fond of that particular solution since it is more like treating the symptoms and not the root cause.

Vladimir

--- "Lever, Charles" <Charles.Lever@netapp.com> wrote:
>i'm wondering what are the common elements here:
>
>is the EEpro 100 ethernet card common to all clients
>that exhibit this problem?  NFSv3 over UDP?  what is
>the nature of the network flood -- ICMP packets, or
>UDP?  does "top" on the client show whether a particular
>process or processes is spinning?
>
>a tcpdump or at least "netstat -s" on the client after
>the network is unplugged might be helpful.
>
>> -----Original Message-----
>> From: Cooke, Alan [mailto:acooke@hp.com]
>> Sent: Friday, May 17, 2002 9:15 AM
>> To: nfs@lists.sourceforge.net
>> Subject: RE: [NFS] RedHat 7.3 crashed NetApp?
>> 
>> 
>> While running the 2.4.18-4smp kernel (RedHat), and testing 
>> NFS3, our NetApp filer running OnTap 6.1.1R2 experienced 
>> massive incoming traffic from the Linux client in question. 
>> The Linux client required rebooting. We have been able to 
>> repeat this behavior, and are suspicious of the network 
>> driver on the Linux client which is using the eth0 driver. A
>> 
>> Sound familiar?
>> 
>> Alan Cooke
>> Hewlett-Packard Company
>> ISS/EDA
>> Office: 281-518-9775
>> Fax    : 281-518-8015
>> Email  : acooke@hp.com
>> 
>> "If everything seems under control, you're just not going 
>> fast enough."
>> -- Mario Andretti
>> 
>> 
>> 
>> 
>> 
>> 
>> 
>> 
>> -----Original Message-----
>> From: H . J . Lu [mailto:hjl@lucon.org]
>> Sent: Thursday, May 16, 2002 5:39 PM
>> To: nfs@lists.sourceforge.net
>> Subject: [NFS] RedHat 7.3 crashed NetApp?
>> 
>> 
>> Has anyone seen
>> 
>> http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=65069
>> 
>> 
>> H.J.
>> 
>> _______________________________________________________________
>> 
>> Have big pipes? SourceForge.net is looking for download 
>> mirrors. We supply
>> the hardware. You get the recognition. Email Us: 
>> bandwidth@sourceforge.net
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>> 
>> _______________________________________________________________
>> 
>> Have big pipes? SourceForge.net is looking for download 
>> mirrors. We supply
>> the hardware. You get the recognition. Email Us: 
>> bandwidth@sourceforge.net
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
>> 
>
>_______________________________________________________________
>
>Hundreds of nodes, one monster rendering program.
>Now that&#8217;s a super model! Visit http://clustering.foundries.sf.net/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

_____________________________________________________________
Want a new web-based email account ? ---> http://www.firstlinux.net

_____________________________________________________________
Promote your group and strengthen ties to your members with email@yourgroup.org by Everyone.net  http://www.everyone.net/?btn=tag

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
