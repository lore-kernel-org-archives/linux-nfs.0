From: "William A. (Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: can not start NFSv4 with Kerberos 5
Date: Tue, 3 Apr 2007 09:18:33 -0400
Message-ID: <89c397150704030618iee707a8v24b1cbeb0dd72502@mail.gmail.com>
References: <1175595021.3798.19.camel@localhost.localdomain>
	<89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
	<1175602407.4063.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1678051304=="
Cc: nfs@lists.sourceforge.net
To: Phillip <phuang@plasmon.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYiuD-0006G6-2b
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 06:18:37 -0700
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYiuD-0004zq-22
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 06:18:39 -0700
Received: by ug-out-1314.google.com with SMTP id z38so294306ugc
	for <nfs@lists.sourceforge.net>; Tue, 03 Apr 2007 06:18:35 -0700 (PDT)
In-Reply-To: <1175602407.4063.51.camel@localhost.localdomain>
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

--===============1678051304==
Content-Type: multipart/alternative;
	boundary="----=_Part_7941_5303196.1175606313817"

------=_Part_7941_5303196.1175606313817
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 4/3/07, Phillip <phuang@plasmon.cn> wrote:
>
> Andy,
>
> Thanks for you kindly reply.
>
> As your comment:
> nfs/<your.host>@<YOUR.REALM>
> and I google the following:
> host/hostname@NT-DNS-REALM-NAME
>
> hostname is the host DNS name, for example, foobar.microsoft.com.
> NT-DNS-REALM-NAME is the uppercase name of the Windows 2000 domain; for
> example, RESKIT.COM.


hostname is the dns name of your host. the realm name is the name of your
kerberos domain.

I have two questions:
> 1. What does the above term "host" mean? Hostname of NFS server, or
> service(nfs)?


this is kerberos speak.

a kerberos service name has a "service" component (host, root, nfs, ldap,
web, or whatever you want) followed by a "/" and then the dns hostname.

NFSv4 requires that the NFSv4 server Kerberos service name is of the form

nfs/<dnshostname>@<KERBEROS.REALM>

the "host" service name is used by many other servers, but not by NFSv4.

the NFSv4 client keytab name is unspecified. so, if you want you can place a
keytab on the client
to be used for NFSv4 - but it is not required.


2. If I set the IP address in the above "<your.host>" field, is it OK?
> How could I set the DNS name since I could not operate on the DNS
> server?



dns name required.

see
http://www.citi.umich.edu/projects/nfsv4/linux/krb5-setup.html for kerberos
setup instructions

and
http://www.citi.umich.edu/projects/nfsv4/linux/    "Instructions" section
for other v4 set-up instructions.

-->Andy


Call me a piggy, but this is just where I am: I'm here for real.
>
> Regards,
> Phillip
>
>
>
> On Tue, 2007-04-03 at 07:46 -0400, William A. (Andy) Adamson wrote:
> >
> >
> > On 4/3/07, Phillip <phuang@plasmon.cn> wrote:
> >         Hi folks,
> >
> >         Currently we plan to use NFSV4 with Kerberos:
> >         KDC: Windows 2K AD
> >
> >         NFSv4 server: CentOS 4.4 with 2.6.20 kernel
> >         # cat /etc/exports
> >         /XFS/NFS4       gss/krb5
> >         (rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)
> >
> >         Client: CentOS 4.4
> >
> >         When I use Ktpass to create keytab:
> >
> >         C:> Ktpass princ administrator/PLASMON.SIT@PLASMON.SIT mapuser
> >         administrator -pass admin out unixmachine.keytab
> >         C:> Ktpass princ root/PLAMONS.SIT@PLASMON.SIT mapuser root -
> >         pass admin
> >         out unixmachine_1.keytab
> >
> >
> >         and copy this output keytabs to NFSv4 server, and then export
> >         them with
> >         kinit well.
> >
> >         However, when I attempt to start NFS service, the rpcsvcgssd
> >         failed.
> >
> >         Then I try to execute these below commands
> >
> >         [root@nfsv4 kevin]# rpc.svcgssd -fvvv
> >         ERROR: GSS-API: error in gss_import_name(): An invalid name
> >         was supplied
> >         - Hostname cannot be canonicalized
> >         unable to obtain root (machine) credentials
> >         do you have a keytab entry for nfs/<your.host>@<YOUR.REALM>
> >         in /etc/krb5.keytab?
> >
> > as the error message on the server said: you need a keytab of the
> > form
> >
> > nfs/<your.host>@<YOUR.REALM>
> >
> > the root/<your.host>@<YOUR.REALM> or
> > administrator/<your.host>@<YOUR.REALM> won/t work.
> >
> > -->Andy
> >
> >
> >         [root@nfsv4 kevin]# rpc.gssd -fvvv
> >         Using keytab file '/etc/krb5.keytab'
> >         Processing keytab entry for principal
> >         'administrator/PLASMON.SIT@PLASMON.SIT'
> >         We will NOT use this entry
> >         (administrator/PLASMON.SIT@PLASMON.SIT)
> >         Processing keytab entry for principal
> >         'root/PLASMON.SIT@PLASMON.SIT'
> >         We will NOT use this entry (root/PLASMON.SIT@PLASMON.SIT)
> >         ERROR: No usable keytab entries found in keytab
> >         '/etc/krb5.keytab'
> >         Do you have a valid keytab entry for
> >         nfs/<your.host>@<YOUR.REALM> in
> >         keytab file /etc/krb5.keytab ?
> >         Continuing without (machine) credentials - nfs4 mounts with
> >         Kerberos
> >         will fail
> >         processing client list
> >
> >
> >         Did I take mistakes in creating keytab?
> >
> >
> >         Please help me fix this issue.
> >         Thanks in advance.
> >
> >         Regards,
> >         Phillip
> >
> >
> >
> >
> >
> -------------------------------------------------------------------------
> >         Take Surveys. Earn Cash. Influence the Future of IT
> >         Join SourceForge.net's Techsay panel and you'll get the chance
> >         to share your
> >         opinions on IT & business topics through brief surveys-and
> >         earn cash
> >         http://www.techsay.com/default.php?
> >         page=join.php&p=sourceforge&CID=DEVDEV
> >         _______________________________________________
> >         NFS maillist  -  NFS@lists.sourceforge.net
> >         https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
>
>

------=_Part_7941_5303196.1175606313817
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div><span class="gmail_quote">On 4/3/07, <b class="gmail_sendername">Phillip</b> &lt;<a href="mailto:phuang@plasmon.cn">phuang@plasmon.cn</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Andy,<br><br>Thanks for you kindly reply.<br><br>As your comment:<br>nfs/&lt;your.host&gt;@&lt;YOUR.REALM&gt;<br>and I google the following:<br>host/hostname@NT-DNS-REALM-NAME<br><br>hostname is the host DNS name, for example, 
<a href="http://foobar.microsoft.com">foobar.microsoft.com</a>.<br>NT-DNS-REALM-NAME is the uppercase name of the Windows 2000 domain; for<br>example, <a href="http://RESKIT.COM">RESKIT.COM</a>.</blockquote><div><br>hostname is the dns name of your host. the realm name is the name of your kerberos domain.&nbsp;
</div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">I have two questions:<br>1. What does the above term &quot;host&quot; mean? Hostname of NFS server, or
<br>service(nfs)?</blockquote><div><br>this is kerberos speak.<br><br>a kerberos service name has a &quot;service&quot; component (host, root, nfs, ldap, web, or whatever you want) followed by a &quot;/&quot; and then the dns hostname.
<br><br>NFSv4 requires that the NFSv4 server Kerberos service name is of the form <br><br>nfs/&lt;dnshostname&gt;@&lt;KERBEROS.REALM&gt;<br><br>the &quot;host&quot; service name is used by many other servers, but not by NFSv4.
<br><br>the NFSv4 client keytab name is unspecified. so, if you want you can place a keytab on the client <br>to be used for NFSv4 - but it is not required.<br>&nbsp;</div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
2. If I set the IP address in the above &quot;&lt;your.host&gt;&quot; field, is it OK?<br>How could I set the DNS name since I could not operate on the DNS<br>server?</blockquote><div><br><br>dns name required.<br><br>see 
<br><a href="http://www.citi.umich.edu/projects/nfsv4/linux/krb5-setup.html">http://www.citi.umich.edu/projects/nfsv4/linux/krb5-setup.html</a> for kerberos setup instructions<br><br>and <br><a href="http://www.citi.umich.edu/projects/nfsv4/linux/">
http://www.citi.umich.edu/projects/nfsv4/linux/</a>&nbsp;&nbsp;&nbsp; &quot;Instructions&quot; section for other v4 set-up instructions.<br><br>--&gt;Andy<br><br></div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Call me a piggy, but this is just where I am: I&#39;m here for real.<br><br>Regards,<br>Phillip<br><br><br><br>On Tue, 2007-04-03 at 07:46 -0400, William A. (Andy) Adamson wrote:<br>&gt;<br>&gt;<br>&gt; On 4/3/07, Phillip &lt;
<a href="mailto:phuang@plasmon.cn">phuang@plasmon.cn</a>&gt; wrote:<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Hi folks,<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Currently we plan to use NFSV4 with Kerberos:<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; KDC: Windows 2K AD<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; NFSv4 server: CentOS 
4.4 with 2.6.20 kernel<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; # cat /etc/exports<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /XFS/NFS4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; gss/krb5<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Client: CentOS 4.4<br>&gt;
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; When I use Ktpass to create keytab:<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; C:&gt; Ktpass princ <a href="mailto:administrator/PLASMON.SIT@PLASMON.SIT">administrator/PLASMON.SIT@PLASMON.SIT</a> mapuser<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; administrator -pass admin out 
unixmachine.keytab<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; C:&gt; Ktpass princ <a href="mailto:root/PLAMONS.SIT@PLASMON.SIT">root/PLAMONS.SIT@PLASMON.SIT</a> mapuser root -<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pass admin<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; out unixmachine_1.keytab<br>&gt;
<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; and copy this output keytabs to NFSv4 server, and then export<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; them with<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kinit well.<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; However, when I attempt to start NFS service, the rpcsvcgssd
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; failed.<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Then I try to execute these below commands<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [root@nfsv4 kevin]# rpc.svcgssd -fvvv<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ERROR: GSS-API: error in gss_import_name(): An invalid name
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; was supplied<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; - Hostname cannot be canonicalized<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unable to obtain root (machine) credentials<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; do you have a keytab entry for nfs/&lt;your.host&gt;@&lt;YOUR.REALM
&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; in /etc/krb5.keytab?<br>&gt;<br>&gt; as the error message on the server said: you need a keytab of the<br>&gt; form<br>&gt;<br>&gt; nfs/&lt;your.host&gt;@&lt;YOUR.REALM&gt;<br>&gt;<br>&gt; the root/&lt;
your.host&gt;@&lt;YOUR.REALM&gt; or<br>&gt; administrator/&lt;your.host&gt;@&lt;YOUR.REALM&gt; won/t work.<br>&gt;<br>&gt; --&gt;Andy<br>&gt;<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; [root@nfsv4 kevin]# rpc.gssd -fvvv<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Using keytab file &#39;/etc/krb5.keytab&#39;
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Processing keytab entry for principal<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#39;<a href="mailto:administrator/PLASMON.SIT@PLASMON.SIT">administrator/PLASMON.SIT@PLASMON.SIT</a>&#39;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; We will NOT use this entry<br>
&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (<a href="mailto:administrator/PLASMON.SIT@PLASMON.SIT">administrator/PLASMON.SIT@PLASMON.SIT</a>)<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Processing keytab entry for principal<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#39;<a href="mailto:root/PLASMON.SIT@PLASMON.SIT">
root/PLASMON.SIT@PLASMON.SIT</a>&#39;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; We will NOT use this entry (<a href="mailto:root/PLASMON.SIT@PLASMON.SIT">root/PLASMON.SIT@PLASMON.SIT</a>)<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ERROR: No usable keytab entries found in keytab
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#39;/etc/krb5.keytab&#39;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Do you have a valid keytab entry for<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; nfs/&lt;your.host&gt;@&lt;YOUR.REALM&gt; in<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; keytab file /etc/krb5.keytab ?<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Continuing without (machine) credentials - nfs4 mounts with
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Kerberos<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; will fail<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; processing client list<br>&gt;<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Did I take mistakes in creating keytab?<br>&gt;<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Please help me fix this issue.
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Thanks in advance.<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Regards,<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Phillip<br>&gt;<br>&gt;<br>&gt;<br>&gt;<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -------------------------------------------------------------------------<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Take Surveys. Earn Cash. Influence the Future of IT
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Join SourceForge.net&#39;s Techsay panel and you&#39;ll get the chance<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; to share your<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; opinions on IT &amp; business topics through brief surveys-and<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; earn cash
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="http://www.techsay.com/default.php">http://www.techsay.com/default.php</a>?<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; page=join.php&amp;p=sourceforge&amp;CID=DEVDEV<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; _______________________________________________
<br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; NFS maillist&nbsp;&nbsp;-&nbsp;&nbsp;<a href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a><br>&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs
</a><br>&gt;<br>&gt;<br><br></blockquote></div><br>

------=_Part_7941_5303196.1175606313817--


--===============1678051304==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1678051304==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1678051304==--
