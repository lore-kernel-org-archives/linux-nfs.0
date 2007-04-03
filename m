From: "William A. (Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: can not start NFSv4 with Kerberos 5
Date: Tue, 3 Apr 2007 07:46:55 -0400
Message-ID: <89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
References: <1175595021.3798.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0737501734=="
Cc: nfs@lists.sourceforge.net
To: Phillip <phuang@plasmon.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYhTT-0001Lq-De
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 04:46:55 -0700
Received: from wr-out-0506.google.com ([64.233.184.227])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYhTV-0001ZD-6G
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 04:46:57 -0700
Received: by wr-out-0506.google.com with SMTP id i20so3094900wra
	for <nfs@lists.sourceforge.net>; Tue, 03 Apr 2007 04:46:56 -0700 (PDT)
In-Reply-To: <1175595021.3798.19.camel@localhost.localdomain>
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

--===============0737501734==
Content-Type: multipart/alternative;
	boundary="----=_Part_7079_8478873.1175600815915"

------=_Part_7079_8478873.1175600815915
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 4/3/07, Phillip <phuang@plasmon.cn> wrote:
>
> Hi folks,
>
> Currently we plan to use NFSV4 with Kerberos:
> KDC: Windows 2K AD
>
> NFSv4 server: CentOS 4.4 with 2.6.20 kernel
> # cat /etc/exports
> /XFS/NFS4       gss/krb5
> (rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)
>
> Client: CentOS 4.4
>
> When I use Ktpass to create keytab:
>
> C:> Ktpass princ administrator/PLASMON.SIT@PLASMON.SIT mapuser
> administrator -pass admin out unixmachine.keytab
> C:> Ktpass princ root/PLAMONS.SIT@PLASMON.SIT mapuser root -pass admin
> out unixmachine_1.keytab
>
>
> and copy this output keytabs to NFSv4 server, and then export them with
> kinit well.
>
> However, when I attempt to start NFS service, the rpcsvcgssd failed.
>
> Then I try to execute these below commands
>
> [root@nfsv4 kevin]# rpc.svcgssd -fvvv
> ERROR: GSS-API: error in gss_import_name(): An invalid name was supplied
> - Hostname cannot be canonicalized
> unable to obtain root (machine) credentials
> do you have a keytab entry for nfs/<your.host>@<YOUR.REALM>
> in /etc/krb5.keytab?


as the error message on the server said: you need a keytab of the form

nfs/<your.host>@<YOUR.REALM>

the root/<your.host>@<YOUR.REALM> or administrator/<your.host>@<YOUR.REALM>
won/t work.

-->Andy

[root@nfsv4 kevin]# rpc.gssd -fvvv
> Using keytab file '/etc/krb5.keytab'
> Processing keytab entry for principal
> 'administrator/PLASMON.SIT@PLASMON.SIT'
> We will NOT use this entry (administrator/PLASMON.SIT@PLASMON.SIT)
> Processing keytab entry for principal 'root/PLASMON.SIT@PLASMON.SIT'
> We will NOT use this entry (root/PLASMON.SIT@PLASMON.SIT)
> ERROR: No usable keytab entries found in keytab '/etc/krb5.keytab'
> Do you have a valid keytab entry for nfs/<your.host>@<YOUR.REALM> in
> keytab file /etc/krb5.keytab ?
> Continuing without (machine) credentials - nfs4 mounts with Kerberos
> will fail
> processing client list
>
>
> Did I take mistakes in creating keytab?
>
>
> Please help me fix this issue.
> Thanks in advance.
>
> Regards,
> Phillip
>
>
>
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share
> your
> opinions on IT & business topics through brief surveys-and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>

------=_Part_7079_8478873.1175600815915
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<br><br><div><span class="gmail_quote">On 4/3/07, <b class="gmail_sendername">Phillip</b> &lt;<a href="mailto:phuang@plasmon.cn">phuang@plasmon.cn</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Hi folks,<br><br>Currently we plan to use NFSV4 with Kerberos:<br>KDC: Windows 2K AD<br><br>NFSv4 server: CentOS 4.4 with 2.6.20 kernel<br># cat /etc/exports<br>/XFS/NFS4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; gss/krb5<br>(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)
<br><br>Client: CentOS 4.4<br><br>When I use Ktpass to create keytab:<br><br>C:&gt; Ktpass princ <a href="mailto:administrator/PLASMON.SIT@PLASMON.SIT">administrator/PLASMON.SIT@PLASMON.SIT</a> mapuser<br>administrator -pass admin out 
unixmachine.keytab<br>C:&gt; Ktpass princ <a href="mailto:root/PLAMONS.SIT@PLASMON.SIT">root/PLAMONS.SIT@PLASMON.SIT</a> mapuser root -pass admin<br>out unixmachine_1.keytab<br><br><br>and copy this output keytabs to NFSv4 server, and then export them with
<br>kinit well.<br><br>However, when I attempt to start NFS service, the rpcsvcgssd failed.<br><br>Then I try to execute these below commands<br><br>[root@nfsv4 kevin]# rpc.svcgssd -fvvv<br>ERROR: GSS-API: error in gss_import_name(): An invalid name was supplied
<br>- Hostname cannot be canonicalized<br>unable to obtain root (machine) credentials<br>do you have a keytab entry for nfs/&lt;your.host&gt;@&lt;YOUR.REALM&gt;<br>in /etc/krb5.keytab?</blockquote><div><br>as the error message on the server said: you need a keytab of the form 
<br><br>nfs/&lt;your.host&gt;@&lt;YOUR.REALM&gt;<br><br>the root/&lt;your.host&gt;@&lt;YOUR.REALM&gt; or administrator/&lt;your.host&gt;@&lt;YOUR.REALM&gt; won/t work.<br><br>--&gt;Andy<br></div><br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
[root@nfsv4 kevin]# rpc.gssd -fvvv<br>Using keytab file &#39;/etc/krb5.keytab&#39;<br>Processing keytab entry for principal<br>&#39;<a href="mailto:administrator/PLASMON.SIT@PLASMON.SIT">administrator/PLASMON.SIT@PLASMON.SIT
</a>&#39;<br>We will NOT use this entry (<a href="mailto:administrator/PLASMON.SIT@PLASMON.SIT">administrator/PLASMON.SIT@PLASMON.SIT</a>)<br>Processing keytab entry for principal &#39;<a href="mailto:root/PLASMON.SIT@PLASMON.SIT">
root/PLASMON.SIT@PLASMON.SIT</a>&#39;<br>We will NOT use this entry (<a href="mailto:root/PLASMON.SIT@PLASMON.SIT">root/PLASMON.SIT@PLASMON.SIT</a>)<br>ERROR: No usable keytab entries found in keytab &#39;/etc/krb5.keytab&#39;
<br>Do you have a valid keytab entry for nfs/&lt;your.host&gt;@&lt;YOUR.REALM&gt; in<br>keytab file /etc/krb5.keytab ?<br>Continuing without (machine) credentials - nfs4 mounts with Kerberos<br>will fail<br>processing client list
<br><br><br>Did I take mistakes in creating keytab?<br><br><br>Please help me fix this issue.<br>Thanks in advance.<br><br>Regards,<br>Phillip<br><br><br><br><br>-------------------------------------------------------------------------
<br>Take Surveys. Earn Cash. Influence the Future of IT<br>Join SourceForge.net&#39;s Techsay panel and you&#39;ll get the chance to share your<br>opinions on IT &amp; business topics through brief surveys-and earn cash<br>
<a href="http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV">http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV</a><br>_______________________________________________
<br>NFS maillist&nbsp;&nbsp;-&nbsp;&nbsp;<a href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a><br><a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a><br><br></blockquote>
</div><br>

------=_Part_7079_8478873.1175600815915--


--===============0737501734==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0737501734==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0737501734==--
