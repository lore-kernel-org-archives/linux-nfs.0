From: "Saurabh Sehgal" <saurabh.r.s@gmail.com>
Subject: Re: Nfs Failover
Date: Wed, 10 Oct 2007 09:38:18 -0400
Message-ID: <2a46ebd60710100638k5665f025vbadb8d7194262f1a@mail.gmail.com>
References: <2a46ebd60710091240k37369e15rbc99b57d26579e8a@mail.gmail.com>
	<20071009195128.GQ22750@fieldses.org> <470BDFB9.30409@cesca.es>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1299659895=="
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: "Jordi Prats" <jprats@cesca.es>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfblR-0001lK-2C
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 06:38:17 -0700
Received: from mu-out-0910.google.com ([209.85.134.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfblV-0000KE-Ly
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 06:38:22 -0700
Received: by mu-out-0910.google.com with SMTP id w9so235664mue
	for <nfs@lists.sourceforge.net>; Wed, 10 Oct 2007 06:38:20 -0700 (PDT)
In-Reply-To: <470BDFB9.30409@cesca.es>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============1299659895==
Content-Type: multipart/alternative;
	boundary="----=_Part_12003_18989059.1192023498946"

------=_Part_12003_18989059.1192023498946
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I will be sure to try that and see if I get the same problem ...

I am exporting an ext3 filesystem ... Does that change anything ?

Thank you,

Saurabh

On 10/9/07, Jordi Prats <jprats@cesca.es> wrote:
>
> To avoid the stale state on your clients you should add a tag to your
> exported filesystems. For example:
>
> /usr 10.0.0.1(rw,sync,no_root_squash,nohide,fsid=1)
> /usr 10.0.0.2(rw,sync,no_root_squash,nohide,fsid=1)
>
> /var 10.0.0.1(rw,sync,no_root_squash,nohide,fsid=2)
> /var 10.0.0.2(rw,sync,no_root_squash,nohide,fsid=2)
>
> regards,
> Jordi
>
> J. Bruce Fields wrote:
> > On Tue, Oct 09, 2007 at 03:40:22PM -0400, Saurabh Sehgal wrote:
> >> Hi all,
> >>
> >> I am trying to do an nfs failover from one server to another in a 4
> node
> >> cluster . During this failover, I have a link from /var/lib/nfs
> directory to
> >> a mount that resides on a shared disk. When i want to move the
> "resources"
> >> from one node to the other ... this is how I go about initiating the
> move :
> >>
> >> 1) /etc/init.d/nfsserver stop
> >> 2) mount /var/lib/nfs on the failover node
> >> 3) move IP address to failover node
> >> 3) /etc/init.d/nfsserver start
> >> 4) /sbin/sm-notify -v <failover ip address>
> >>
> >> Are these the correct steps ? What I end up getting is a Stale NFS File
> >> handle on all client nodes, until I unmount and remount them again. For
> the
> >> purpose of my application this mount/unmount of clients is undesirable
> .
> >> What should I do ? Any help would be appreciated.
> >
> > What filesystem are you exporting?
> >
> > --b.
> >
> >
> -------------------------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc.
> > Still grepping through log files to find problems?  Stop.
> > Now Search log events and configuration files using AJAX and a browser.
> > Download your FREE copy of Splunk now >> http://get.splunk.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
>

------=_Part_12003_18989059.1192023498946
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi, <br><br>I will be sure to try that and see if I get the same problem ...<br><br>I am exporting an ext3 filesystem ... Does that change anything ?<br><br>Thank you, <br><br>Saurabh<br><br><div><span class="gmail_quote">
On 10/9/07, <b class="gmail_sendername">Jordi Prats</b> &lt;<a href="mailto:jprats@cesca.es">jprats@cesca.es</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
To avoid the stale state on your clients you should add a tag to your<br>exported filesystems. For example:<br><br>/usr 10.0.0.1(rw,sync,no_root_squash,nohide,fsid=1)<br>/usr 10.0.0.2(rw,sync,no_root_squash,nohide,fsid=1)
<br><br>/var 10.0.0.1(rw,sync,no_root_squash,nohide,fsid=2)<br>/var 10.0.0.2(rw,sync,no_root_squash,nohide,fsid=2)<br><br>regards,<br>Jordi<br><br>J. Bruce Fields wrote:<br>&gt; On Tue, Oct 09, 2007 at 03:40:22PM -0400, Saurabh Sehgal wrote:
<br>&gt;&gt; Hi all,<br>&gt;&gt;<br>&gt;&gt; I am trying to do an nfs failover from one server to another in a 4 node<br>&gt;&gt; cluster . During this failover, I have a link from /var/lib/nfs directory to<br>&gt;&gt; a mount that resides on a shared disk. When i want to move the &quot;resources&quot;
<br>&gt;&gt; from one node to the other ... this is how I go about initiating the move :<br>&gt;&gt;<br>&gt;&gt; 1) /etc/init.d/nfsserver stop<br>&gt;&gt; 2) mount /var/lib/nfs on the failover node<br>&gt;&gt; 3) move IP address to failover node
<br>&gt;&gt; 3) /etc/init.d/nfsserver start<br>&gt;&gt; 4) /sbin/sm-notify -v &lt;failover ip address&gt;<br>&gt;&gt;<br>&gt;&gt; Are these the correct steps ? What I end up getting is a Stale NFS File<br>&gt;&gt; handle on all client nodes, until I unmount and remount them again. For the
<br>&gt;&gt; purpose of my application this mount/unmount of clients is undesirable .<br>&gt;&gt; What should I do ? Any help would be appreciated.<br>&gt;<br>&gt; What filesystem are you exporting?<br>&gt;<br>&gt; --b.<br>
&gt;<br>&gt; -------------------------------------------------------------------------<br>&gt; This SF.net email is sponsored by: Splunk Inc.<br>&gt; Still grepping through log files to find problems?&nbsp;&nbsp;Stop.<br>&gt; Now Search log events and configuration files using AJAX and a browser.
<br>&gt; Download your FREE copy of Splunk now &gt;&gt; <a href="http://get.splunk.com/">http://get.splunk.com/</a><br>&gt; _______________________________________________<br>&gt; NFS maillist&nbsp;&nbsp;-&nbsp;&nbsp;<a href="mailto:NFS@lists.sourceforge.net">
NFS@lists.sourceforge.net</a><br>&gt; <a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a><br>&gt;<br>&gt;<br></blockquote></div><br>

------=_Part_12003_18989059.1192023498946--


--===============1299659895==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1299659895==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1299659895==--
