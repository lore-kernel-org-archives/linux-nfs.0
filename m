From: "Felderi Santiago" <cibao5@gmail.com>
Subject: Re: Kerberized NFSv4 with AD - Errors received
Date: Tue, 30 Oct 2007 16:02:56 -0400
Message-ID: <cf8a6bbc0710301302j1f8e014en19d91068fcb03b93@mail.gmail.com>
References: <cf8a6bbc0710300914r6302613emf09dc5d445cbe586@mail.gmail.com>
	<4d569c330710300940q7ee25e95g47ab5395f4917e34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0923020106=="
Cc: nfs@lists.sourceforge.net
To: "Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImxIc-0005Yf-TH
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 13:02:54 -0700
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ImxIg-0007Ll-Hs
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 13:03:00 -0700
Received: by ug-out-1314.google.com with SMTP id m2so186661uge
	for <nfs@lists.sourceforge.net>; Tue, 30 Oct 2007 13:02:57 -0700 (PDT)
In-Reply-To: <4d569c330710300940q7ee25e95g47ab5395f4917e34@mail.gmail.com>
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

--===============0923020106==
Content-Type: multipart/alternative;
	boundary="----=_Part_1668_27618838.1193774577024"

------=_Part_1668_27618838.1193774577024
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

We're not really seeing an error perse but the Kerberized mount is not
working.

Sorry for not being clear.  I updated the keytab and included additional
servicePrincipalNames for nfs, so nfs/hostname.domainname.com.  I also
changed the UPN of the computer account.

I am testing on:

SUSE SLES 10 SP1 with nfs-utils-1.0.7-36.26

I ran a Network trace and see a Kerberos error which is a step in the right
direction in terms of figuring out what's going on.  I used Wireshark and
see the following.  Hmmm...wonder what's going on.

134 2.775752 172.17.0.159 172.17.0.44 KRB5 KRB Error:
KRB5KRB_ERR_RESPONSE_TOO_BIG[Packet size limited during capture]

Thanks for the help!

Fel.


On 10/30/07, Kevin Coffman <kwc@citi.umich.edu> wrote:
>
> On 10/30/07, Felderi Santiago <cibao5@gmail.com> wrote:
> > Hello everyone,
> >
> > I am working on trying to get Kerberized NFSv4 working with AD.  At this
> > point everything seems to be setup correctly.  The machine has been
> joined
> > to AD, the keytab has been updated with the appropriate entries and the
> > computer account has the appropriate servicePrincipal and userPrincipal
> > Names.  The Kerberized NFS Share resides on a Filer.
> >
> > When trying to mount the share on the client side I get the following
> error
> > messages.
> >
> > Does anyone understand why we're getting this error?  Any help or
> insight
> > would be very appreciated.
> >
> > Thanks!
> >
> > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list
> Oct
> > 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct
> 29
> > 20:03:33 dev-unix-shell01 rpc.gssd[3284]: handling krb5 upcall Oct 29
> > 20:03:33 dev-unix-shell01 rpc.gssd[3284]: Using keytab file
> > '/etc/krb5.keytab'
> > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: INFO: Credentials in CC
> > 'FILE:/tmp/krb5cc_machine_<DOMAIN>are good until 1193722038
> > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using
> > FILE:/tmp/krb5cc_machine_<DOMAIN> as credentials cache for
> > machine creds Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using
> > environment variable to select krb5 ccache
> > FILE:/tmp/krb5cc_machine_<DOMAIN>
> > Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating context using
> euid
> > 0 (save_uid 0) Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating
> tcp
> > client for server prod-fs-sv1.<domainname>
> > Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: creating context with
> > server nfs@prod-fs-sv1.<domain_name>
> > Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: DEBUG:
> > serialize_krb5_ctx: lucid version!
> > Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: doing downcall Oct 29
> > 20:03:34 dev-unix-shell01 rpc.gssd[3284]: processing client list
>
> There is no error message here.  This is all normal, apparently
> successful, debug output.
>
> What error are you seeing?
>
> BTW, you said, "the keytab has been updated with the appropriate
> entries".  I'm not sure what this means, but I hope it does not mean
> that keys for non-supported enctypes were simply manually removed from
> the keytab file using ktutil.
>
> K.C.
>

------=_Part_1668_27618838.1193774577024
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<div>&nbsp;</div>
<div>We&#39;re not really seeing an error perse but the Kerberized mount is not working.</div>
<div>&nbsp;</div>
<div>Sorry for not being clear.&nbsp; I updated the keytab and included additional servicePrincipalNames for nfs, so nfs/hostname.domainname.com.&nbsp; I also changed the UPN of the computer account.</div>
<div>&nbsp;</div>
<div>I am testing on:</div>
<div><font size="2"></font>&nbsp;</div>
<div><font size="2">SUSE SLES 10 SP1 with&nbsp;nfs-utils-1.0.7-36.26</font></div>
<div><font size="2">&nbsp;</font></div>
<div>I ran a Network trace and see a Kerberos error which is a step in the right direction in terms of figuring out what&#39;s going on.&nbsp; I used Wireshark and see the following.&nbsp; Hmmm...wonder what&#39;s going on.&nbsp; </div>

<div>&nbsp;</div>
<div>134&nbsp;2.775752&nbsp;<a href="http://172.17.0.159">172.17.0.159</a>&nbsp;<a href="http://172.17.0.44">172.17.0.44</a>&nbsp;KRB5&nbsp;KRB Error: KRB5KRB_ERR_RESPONSE_TOO_BIG[Packet size limited during capture]</div>
<div>&nbsp;</div>
<div>Thanks for the help!</div>
<div>&nbsp;</div>
<div>Fel.<br><br>&nbsp;</div>
<div><span class="gmail_quote">On 10/30/07, <b class="gmail_sendername">Kevin Coffman</b> &lt;<a href="mailto:kwc@citi.umich.edu">kwc@citi.umich.edu</a>&gt; wrote:</span>
<blockquote class="gmail_quote" style="PADDING-LEFT: 1ex; MARGIN: 0px 0px 0px 0.8ex; BORDER-LEFT: #ccc 1px solid">On 10/30/07, Felderi Santiago &lt;<a href="mailto:cibao5@gmail.com">cibao5@gmail.com</a>&gt; wrote:<br>&gt; Hello everyone,
<br>&gt;<br>&gt; I am working on trying to get Kerberized NFSv4 working with AD.&nbsp;&nbsp;At this<br>&gt; point everything seems to be setup correctly.&nbsp;&nbsp;The machine has been joined<br>&gt; to AD, the keytab has been updated with the appropriate entries and the
<br>&gt; computer account has the appropriate servicePrincipal and userPrincipal<br>&gt; Names.&nbsp;&nbsp;The Kerberized NFS Share resides on a Filer.<br>&gt;<br>&gt; When trying to mount the share on the client side I get the following error
<br>&gt; messages.<br>&gt;<br>&gt; Does anyone understand why we&#39;re getting this error?&nbsp;&nbsp;Any help or insight<br>&gt; would be very appreciated.<br>&gt;<br>&gt; Thanks!<br>&gt;<br>&gt; Oct 29 20:03:33 dev-unix-shell01 
rpc.gssd[3284]: processing client list Oct<br>&gt; 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: processing client list Oct 29<br>&gt; 20:03:33 dev-unix-shell01 rpc.gssd[3284]: handling krb5 upcall Oct 29<br>&gt; 20:03:33 dev-unix-shell01 
rpc.gssd[3284]: Using keytab file<br>&gt; &#39;/etc/krb5.keytab&#39;<br>&gt; Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: INFO: Credentials in CC<br>&gt; &#39;FILE:/tmp/krb5cc_machine_&lt;DOMAIN&gt;are good until 1193722038
<br>&gt; Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using<br>&gt; FILE:/tmp/krb5cc_machine_&lt;DOMAIN&gt; as credentials cache for<br>&gt; machine creds Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: using<br>&gt; environment variable to select krb5 ccache
<br>&gt; FILE:/tmp/krb5cc_machine_&lt;DOMAIN&gt;<br>&gt; Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating context using euid<br>&gt; 0 (save_uid 0) Oct 29 20:03:33 dev-unix-shell01 rpc.gssd[3284]: creating tcp<br>
&gt; client for server prod-fs-sv1.&lt;domainname&gt;<br>&gt; Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: creating context with<br>&gt; server nfs@prod-fs-sv1.&lt;domain_name&gt;<br>&gt; Oct 29 20:03:34 dev-unix-shell01 
rpc.gssd[3284]: DEBUG:<br>&gt; serialize_krb5_ctx: lucid version!<br>&gt; Oct 29 20:03:34 dev-unix-shell01 rpc.gssd[3284]: doing downcall Oct 29<br>&gt; 20:03:34 dev-unix-shell01 rpc.gssd[3284]: processing client list<br>
<br>There is no error message here.&nbsp;&nbsp;This is all normal, apparently<br>successful, debug output.<br><br>What error are you seeing?<br><br>BTW, you said, &quot;the keytab has been updated with the appropriate<br>entries&quot;.&nbsp;&nbsp;I&#39;m not sure what this means, but I hope it does not mean
<br>that keys for non-supported enctypes were simply manually removed from<br>the keytab file using ktutil.<br><br>K.C.<br></blockquote></div><br>

------=_Part_1668_27618838.1193774577024--


--===============0923020106==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============0923020106==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0923020106==--
