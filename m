From: Blake Golliher <golliher@yahoo-inc.com>
Subject: Re: bug in linux mount? (says NetApp)
Date: Tue, 11 Jul 2006 17:40:14 -0700
Message-ID: <b7c76e8ece93a4f6008145e18efe9ed3@corp.yahoo.com>
References: <44B3F547.9010507@amd.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset="us-ascii"
Cc: autofs@linux.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0Smj-0000Jc-3m
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 17:41:01 -0700
Received: from mrout2-b.corp.dcn.yahoo.com ([216.109.112.28])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G0Smh-00078Q-1O
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 17:41:01 -0700
In-Reply-To: <44B3F547.9010507@amd.com>
To: gregory.baker@amd.com
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

What version of OnTap are you running?

-Blake

On Jul 11, 2006, at 12:00 PM, Gregory Baker wrote:

>
> We have thousands of linux clients hitting netapp file servers (many
> 3500 series, clustered) on a local gigabit LAN.  From time to time,
> applications return "file not found" when attempting to automount a
> directory and access a file.  An example of this is a long running
> process, which reads in data, processes it for hours (in which time the
> filesystem is unmounted) then tries to read more data from that mount
> point (which causes a "file not found" error in the application).  This
> occurs about 1/100th of the time.
>
> Researching at Netapp turns up this bit by Chuck Lever (Linux NFS
> contributer)
>
> "Using the Linux NFS Client with Network Appliance Filers"
> http://www.netapp.com/libr ary/tr/3183.pdf  (February 2006)
>
> page 10 says...
>
> "Due to a bug in the mount command, the default retransmission timeout
> value on Linux for NFS over TCP is quite small...To obtain standard
> behavior, we strongly recommend using "timeo=600, retrans=2" explicitly
> when mounting via TCP."
>
> Our defaults (assuming man pages are correct, RedHat Enterprise Linux  
> 3)
> would be timeo=7, retrans=3, which translates to 7+14+28+56 = 105  
> tenths
> of a second (10 seconds).  It appears netapp is suggesting waiting
> 600+600 = 1200 tenths (120 seconds) before giving up on the mount  
> command...
>
> * What "bug" in the mount command do you believe NetApp is talking  
> about?
>
> * What do you think proper options for NFS auto/mounts would be for
> extremely busy centralized NFS filers?
>
> * What is the reference standard behavior?
>
> Thanks,
>
> --Greg
>
> --  
> ----------------------------------------------------------------------
> Greg Baker                                         512-602-3287 (work)
> gregory.baker@amd.com                              512-602-6970 (fax)
> 5900 E. Ben White Blvd MS 626                      512-555-1212 (info)
> Austin, TX 78741
>
>
>
>
>
> ----------------------------------------------------------------------- 
> --
> Using Tomcat but need to do more? Need to support web services,  
> security?
> Get stuff done quickly with pre-integrated technology to make your job  
> easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache  
> Geronimo
> http://sel.as-us.falkag.net/sel? 
> cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
