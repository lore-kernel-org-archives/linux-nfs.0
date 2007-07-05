From: "Myles Uyema" <mlists@uyema.net>
Subject: Re: 'noacl' NFS parameter seems ineffective (Fedora Core 7)
Date: Thu, 5 Jul 2007 14:39:34 -0700
Message-ID: <a90f74cc0707051439t3f471394s1e750ec5c3e4befb@mail.gmail.com>
References: <a90f74cc0707051401p38167340s955be299a807710d@mail.gmail.com>
	<468D6064.3080307@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0445328718=="
Cc: nfs@lists.sourceforge.net
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6Z31-0002HV-7k
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 14:39:35 -0700
Received: from ug-out-1314.google.com ([66.249.92.168])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6Z32-0003l4-Ko
	for nfs@lists.sourceforge.net; Thu, 05 Jul 2007 14:39:38 -0700
Received: by ug-out-1314.google.com with SMTP id m2so602883uge
	for <nfs@lists.sourceforge.net>; Thu, 05 Jul 2007 14:39:35 -0700 (PDT)
In-Reply-To: <468D6064.3080307@redhat.com>
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

--===============0445328718==
Content-Type: multipart/alternative;
	boundary="----=_Part_137195_3740438.1183671574802"

------=_Part_137195_3740438.1183671574802
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thanks for the clarification.  I don't suppose there's an option to do what
I've described?  Rather - assume that there is no acl, no uid
mapping/translation on the server side?

On 7/5/07, Peter Staubach <staubach@redhat.com> wrote:
>
> Myles Uyema wrote:
> > If I understand the explanation of the 'noacl' parameter, it should
> > prevent ACCESS calls right?  I'm not seeing this occurring on Fedora
> > Core 7 (2.6.21-1.3228.fc7 #1 SMP Tue Jun 12 14:56:37 EDT 2007 x86_64
> > x86_64 x86_64 GNU/Linux)
> >
> > I mounted using tcp,noacl,rsize=32768,wsize=32768.  The NFS server is
> > a NetApp filer running 7.2.1.1 <http://7.2.1.1>, and is a unix-only
> > filesystem.
> >
> > Then I ran a script to 'dd' 286 files on the NFS mountpoint.  The
> > script ran as UID 48.
> > 340 reads
> > 286 getattr
> > 286 access
> >
> > The nfsstat showed my client still performing ACCESS calls.  I'd like
> > to believe that the GETATTR has already verified the permission bits,
> > and thus an ACCESS shouldn't be necessary.
>
> Actually, all that the "noacl" mount option means is to not attempt
> to get or set or ACLs on the server.  It does not affect the security
> checking that the client does to verify access.
>
> The permission bits are not enough to determine access permissions.
> Root mapping on the server is an easy example of this.  Therefore,
> the client always goes over the wire to query the server for the
> permissions that it will allow.
>
>     Thanx...
>
>        ps
>

------=_Part_137195_3740438.1183671574802
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Thanks for the clarification.&nbsp; I don&#39;t suppose there&#39;s an option to do what I&#39;ve described?&nbsp; Rather - assume that there is no acl, no uid mapping/translation on the server side?<br><br><div><span class="gmail_quote">
On 7/5/07, <b class="gmail_sendername">Peter Staubach</b> &lt;<a href="mailto:staubach@redhat.com">staubach@redhat.com</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
Myles Uyema wrote:<br>&gt; If I understand the explanation of the &#39;noacl&#39; parameter, it should<br>&gt; prevent ACCESS calls right?&nbsp;&nbsp;I&#39;m not seeing this occurring on Fedora<br>&gt; Core 7 (2.6.21-1.3228.fc7 #1 SMP Tue Jun 12 14:56:37 EDT 2007 x86_64
<br>&gt; x86_64 x86_64 GNU/Linux)<br>&gt;<br>&gt; I mounted using tcp,noacl,rsize=32768,wsize=32768.&nbsp;&nbsp;The NFS server is<br>&gt; a NetApp filer running <a href="http://7.2.1.1">7.2.1.1</a> &lt;<a href="http://7.2.1.1">http://7.2.1.1
</a>&gt;, and is a unix-only<br>&gt; filesystem.<br>&gt;<br>&gt; Then I ran a script to &#39;dd&#39; 286 files on the NFS mountpoint.&nbsp;&nbsp;The<br>&gt; script ran as UID 48.<br>&gt; 340 reads<br>&gt; 286 getattr<br>&gt; 286 access
<br>&gt;<br>&gt; The nfsstat showed my client still performing ACCESS calls.&nbsp;&nbsp;I&#39;d like<br>&gt; to believe that the GETATTR has already verified the permission bits,<br>&gt; and thus an ACCESS shouldn&#39;t be necessary.
<br><br>Actually, all that the &quot;noacl&quot; mount option means is to not attempt<br>to get or set or ACLs on the server.&nbsp;&nbsp;It does not affect the security<br>checking that the client does to verify access.<br><br>The permission bits are not enough to determine access permissions.
<br>Root mapping on the server is an easy example of this.&nbsp;&nbsp;Therefore,<br>the client always goes over the wire to query the server for the<br>permissions that it will allow.<br><br>&nbsp;&nbsp;&nbsp;&nbsp;Thanx...<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ps<br></blockquote>
</div><br>

------=_Part_137195_3740438.1183671574802--


--===============0445328718==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0445328718==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0445328718==--
