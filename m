From: "Christopher Smith" <csmithere@gmail.com>
Subject: Re: Update to the NFS Howto
Date: Tue, 18 Jul 2006 10:40:56 -0400
Message-ID: <2b585fc90607180740u58cf2b32vb26d29d6cb707649@mail.gmail.com>
References: <4489840C0200006B0000515A@lucius.provo.novell.com>
	<2b585fc90606120403w755dfe76gb185ca135eed3732@mail.gmail.com>
	<2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com>
	<44B7C69E.2C84.006B.0@novell.com>
	<4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com>
	<44BD3638.2C84.006B.0@novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1965605390=="
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2qmT-0002og-1H
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 07:42:37 -0700
Received: from py-out-1112.google.com ([64.233.166.180])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2qmS-00074v-Tq
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 07:42:37 -0700
Received: by py-out-1112.google.com with SMTP id f25so421586pyf
	for <nfs@lists.sourceforge.net>; Tue, 18 Jul 2006 07:42:33 -0700 (PDT)
To: "Chakravarthi P" <pchakravarthi@novell.com>
In-Reply-To: <44BD3638.2C84.006B.0@novell.com>
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

--===============1965605390==
Content-Type: multipart/alternative;
	boundary="----=_Part_29983_26675006.1153233656217"

------=_Part_29983_26675006.1153233656217
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Chax--

Sure, I'l just need to merge /reformat it Docbook XML, incorporate it into
the current document, and rebuild the files.  That will take a bit of time,
but not a big deal at all.

I'll let you know when its complete (hopefully in the next 24 hours or so).

Best,
CMS

On 7/18/06, Chakravarthi P <pchakravarthi@novell.com> wrote:
>
> thanx Kevin for those comments.
> the modified how to portions are
> attached.
>
> Chris, Kevin and others please getback
> if you find any issues.
>
> Chris, is this the way you want the chapters
> to be in the HOWTO you are maintaining?
>
> thanx
> chax.
>
> >>> On Fri, Jul 14, 2006 at  7:33 PM, in message
> <4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com>, "Kevin
> Coffman"
> <kwc@citi.umich.edu> wrote:
> > Some quick comments:
> >
> > The following are more differences between suse and redhat:
> >
> > suse                                 redhat
> > ---------------------------
> ------------------------------
> > /etc/init.d/nfsserver             /etc/init.d/nfs
> > /etc/init.d/gssd                   /etc/init.d/rpcgssd
> > /etc/init.d/svcgssd              /etc/init.d/rpcsvcgssd
> > /etc/init.d/idmapd               /etc/init.d/rpcidmapd
> >
> > In /etc/sysconfig/nfs:
> >
> > NFS_SECURITY_GSS       SECURE_NFS
> >
> > Leaving off the path entirely in the /etc/gssapi_mech.conf file may
> be
> > a work- around for 32/64 compatibility:
> >
> > # library                               initialization function
> > # =================      ==========================
> > # The MIT K5 gssapi library, use special function for
> initialization.
> > libgssapi_krb5.so                 mechglue_internal_krb5_init
> >
> >
> > The other idmapd mapping method is "umich_ldap", not "ldap_umich".
> >
> > Thanks,
> > K.C.
> >
> >
> > On 7/14/06, Chakravarthi P <pchakravarthi@novell.com> wrote:
> >>
> >> Cms and all
> >>
> >>   there are 3 sections in the attached txt file for addressing
> 'howto'
> >> -
> >>   specific to nfsv4 and kerberos.
> >>   i have marked a $$$ whenever something mentioned is suse specfic
> >>   or if it is not specific to NFSv4 but NFS in general.
> >>   please get back with your comments.
> >>
> >> regards,
> >> chax.
> >>
> >>
> >>
> >>
> >> >>> On Mon, Jun 12, 2006 at  7:03 PM, in message
> >> <2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com>,
> >> "Christopher
> >> Smith" <csmithere@gmail.com> wrote:
> >> > Chax--
> >> >
> >> > Thank you very much for what you have submitted.  A few comments:
> >> >
> >> > a) Some of the information tin the README is general to Linux,
> and
> >> > applies to all 2.6 implementations.
> >> > b) Some of the information here applies to SuSE specifically.
> >> > c) The Kerberos configuration section applies to both NFS Version
> 3
> >> as
> >> > well as NFS Version 4.
> >> >
> >> > What I would suggest is we do the following:
> >> >
> >> > * Break out the portions that apply specifically to NFS Version 4
> >> into
> >> > sections 3 and 4 of the HOWTO for server and client
> configuration.
> >> > * Break out the Kerberos documentation you've generated into a
> >> > subsection of the Security portion of the HOWTO, since it applies
> to
> >> > all NFS versions.
> >> > * Add notation where specific SuSE related configuration is
> >> required.
> >> >
> >> > Either you or I can do this.  Its up to you.
> >> >
> >> > Is this acceptable?
> >> >
> >> > Best,
> >> > CMS
> >> >
> >> >
> >>
> >>
> >>
> >>
> >>
> >>
> >>
> -------------------------------------------------------------------------
> >> Using Tomcat but need to do more? Need to support web services,
> security?
> >> Get stuff done quickly with pre- integrated technology to make your
> job easier
> >> Download IBM WebSphere Application Server v.1.0.1 based on Apache
> Geronimo
> >> http://sel.as-
> us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> >>
> >>
> >> _______________________________________________
> >> NFS maillist  -   NFS@lists.sourceforge.net
> >> https://lists.sourceforge.net/lists/listinfo/nfs
> >>
> >>
> >>
> >>
>
>
>
>
>


-- 
CMS
--
Christopher M. Smith
csmithere@gmail.com

------=_Part_29983_26675006.1153233656217
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Chax--<br><br>Sure, I'l just need to merge /reformat it Docbook XML, incorporate it into the current document, and rebuild the files.&nbsp; That will take a bit of time, but not a big deal at all.&nbsp; <br><br>I'll let you know when its complete (hopefully in the next 24 hours or so).
<br><br>Best,<br>CMS<br><br><div><span class="gmail_quote">On 7/18/06, <b class="gmail_sendername">Chakravarthi P</b> &lt;<a href="mailto:pchakravarthi@novell.com">pchakravarthi@novell.com</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
thanx Kevin for those comments.<br>the modified how to portions are<br>attached.<br><br>Chris, Kevin and others please getback<br>if you find any issues.<br><br>Chris, is this the way you want the chapters<br>to be in the HOWTO you are maintaining?
<br><br>thanx<br>chax.<br><br>&gt;&gt;&gt; On Fri, Jul 14, 2006 at&nbsp;&nbsp;7:33 PM, in message<br>&lt;<a href="mailto:4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com">4d569c330607140703r3a81f30ds596235774e3af61b@mail.gmail.com
</a>&gt;, &quot;Kevin<br>Coffman&quot;<br>&lt;<a href="mailto:kwc@citi.umich.edu">kwc@citi.umich.edu</a>&gt; wrote:<br>&gt; Some quick comments:<br>&gt;<br>&gt; The following are more differences between suse and redhat:<br>
&gt;<br>&gt; suse&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; redhat<br>&gt; ---------------------------<br>------------------------------<br>&gt; /etc/init.d/nfsserver&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /etc/init.d/nfs<br>&gt; /etc/init.d/gssd&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /etc/init.d/rpcgssd
<br>&gt; /etc/init.d/svcgssd&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/etc/init.d/rpcsvcgssd<br>&gt; /etc/init.d/idmapd&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /etc/init.d/rpcidmapd<br>&gt;<br>&gt; In /etc/sysconfig/nfs:<br>&gt;<br>&gt; NFS_SECURITY_GSS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; SECURE_NFS<br>&gt;
<br>&gt; Leaving off the path entirely in the /etc/gssapi_mech.conf file may<br>be<br>&gt; a work- around for 32/64 compatibility:<br>&gt;<br>&gt; # library&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; initialization function<br>&gt; # =================&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;==========================
<br>&gt; # The MIT K5 gssapi library, use special function for<br>initialization.<br>&gt; libgssapi_krb5.so&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mechglue_internal_krb5_init<br>&gt;<br>&gt;<br>&gt; The other idmapd mapping method is &quot;umich_ldap&quot;, not &quot;ldap_umich&quot;.
<br>&gt;<br>&gt; Thanks,<br>&gt; K.C.<br>&gt;<br>&gt;<br>&gt; On 7/14/06, Chakravarthi P &lt;<a href="mailto:pchakravarthi@novell.com">pchakravarthi@novell.com</a>&gt; wrote:<br>&gt;&gt;<br>&gt;&gt; Cms and all<br>&gt;&gt;
<br>&gt;&gt;&nbsp;&nbsp; there are 3 sections in the attached txt file for addressing<br>'howto'<br>&gt;&gt; -<br>&gt;&gt;&nbsp;&nbsp; specific to nfsv4 and kerberos.<br>&gt;&gt;&nbsp;&nbsp; i have marked a $$$ whenever something mentioned is suse specfic
<br>&gt;&gt;&nbsp;&nbsp; or if it is not specific to NFSv4 but NFS in general.<br>&gt;&gt;&nbsp;&nbsp; please get back with your comments.<br>&gt;&gt;<br>&gt;&gt; regards,<br>&gt;&gt; chax.<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>
&gt;&gt; &gt;&gt;&gt; On Mon, Jun 12, 2006 at&nbsp;&nbsp;7:03 PM, in message<br>&gt;&gt; &lt;<a href="mailto:2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com">2b585fc90606120633n746a8a6ex9d6105c23a872bc3@mail.gmail.com</a>
&gt;,<br>&gt;&gt; &quot;Christopher<br>&gt;&gt; Smith&quot; &lt;<a href="mailto:csmithere@gmail.com">csmithere@gmail.com</a>&gt; wrote:<br>&gt;&gt; &gt; Chax--<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; Thank you very much for what you have submitted.&nbsp;&nbsp;A few comments:
<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; a) Some of the information tin the README is general to Linux,<br>and<br>&gt;&gt; &gt; applies to all 2.6 implementations.<br>&gt;&gt; &gt; b) Some of the information here applies to SuSE specifically.
<br>&gt;&gt; &gt; c) The Kerberos configuration section applies to both NFS Version<br>3<br>&gt;&gt; as<br>&gt;&gt; &gt; well as NFS Version 4.<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; What I would suggest is we do the following:
<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; * Break out the portions that apply specifically to NFS Version 4<br>&gt;&gt; into<br>&gt;&gt; &gt; sections 3 and 4 of the HOWTO for server and client<br>configuration.<br>&gt;&gt; &gt; * Break out the Kerberos documentation you've generated into a
<br>&gt;&gt; &gt; subsection of the Security portion of the HOWTO, since it applies<br>to<br>&gt;&gt; &gt; all NFS versions.<br>&gt;&gt; &gt; * Add notation where specific SuSE related configuration is<br>&gt;&gt; required.
<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; Either you or I can do this.&nbsp;&nbsp;Its up to you.<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; Is this acceptable?<br>&gt;&gt; &gt;<br>&gt;&gt; &gt; Best,<br>&gt;&gt; &gt; CMS<br>&gt;&gt; &gt;<br>&gt;&gt; &gt;
<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>-------------------------------------------------------------------------<br>&gt;&gt; Using Tomcat but need to do more? Need to support web services,
<br>security?<br>&gt;&gt; Get stuff done quickly with pre- integrated technology to make your<br>job easier<br>&gt;&gt; Download IBM WebSphere Application Server v.1.0.1 based on Apache<br>Geronimo<br>&gt;&gt; <a href="http://sel.as-">
http://sel.as-</a><br><a href="http://us.falkag.net/sel?cmd=lnk&amp;kid=120709&amp;bid=263057&amp;dat=121642">us.falkag.net/sel?cmd=lnk&amp;kid=120709&amp;bid=263057&amp;dat=121642</a><br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt; _______________________________________________
<br>&gt;&gt; NFS maillist&nbsp;&nbsp;-&nbsp;&nbsp; <a href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net</a><br>&gt;&gt; <a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs
</a><br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&gt;<br><br><br><br><br></blockquote></div><br><br clear="all"><br>-- <br>CMS<br>--<br>Christopher M. Smith<br><a href="mailto:csmithere@gmail.com">csmithere@gmail.com</a>

------=_Part_29983_26675006.1153233656217--


--===============1965605390==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1965605390==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1965605390==--
