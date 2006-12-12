From: "Warren Beldad" <advisory22@gmail.com>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Tue, 12 Dec 2006 15:52:20 +0800
Message-ID: <b5ba2f6a0612112352y70accccs9571e8da3628280@mail.gmail.com>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
	<45704A4A.6000007@poochiereds.net>
	<17779.42545.642976.873602@cse.unsw.edu.au>
	<4574392D.9080807@poochiereds.net>
	<17788.44467.578376.702580@cse.unsw.edu.au>
	<457CD334.6080700@redhat.com>
	<17790.229.867008.833159@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2111144816=="
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gu2R2-00056a-OK
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 23:52:21 -0800
Received: from ag-out-0708.google.com ([72.14.246.245])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gu2R3-00045H-Ca
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 23:52:22 -0800
Received: by ag-out-0708.google.com with SMTP id 8so1159414agc
	for <nfs@lists.sourceforge.net>; Mon, 11 Dec 2006 23:52:20 -0800 (PST)
To: "Neil Brown" <neilb@suse.de>
In-Reply-To: <17790.229.867008.833159@cse.unsw.edu.au>
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

--===============2111144816==
Content-Type: multipart/alternative;
	boundary="----=_Part_112679_27381761.1165909940005"

------=_Part_112679_27381761.1165909940005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

thanks for opening up this mail.
this is really my old problem, I used showmount -a to get who is mounted but
its not reporting correctly. It includes the previous mounts until
everything is messed up and you can no longer trust anything. I hope this
can be improved at least. :-)
I would prefer IP address than hostnames.

warren

On 12/12/06, Neil Brown <neilb@suse.de> wrote:
>
> On Sunday December 10, jlayton@redhat.com wrote:
> > Neil Brown wrote:
> >  > So I'm not happy with any patch that removes client_compose and
> >  > client_member in favour of client_resolve.
> >  >
> >
> > Here's where I'm confused. I don't see how the patch I proposed loses
> any
> > information:
> >
> > In the old method, we get an IP address and we build a list of client
> > hostnames (in no particular order), using repeated calls to the
> client_check
> > function. We then roll through the list of exports and make repeated
> > calls to client_member to compare the m_client of the export against the
> > list. If it doesn't match, we go to the next export.
> >
> > With my patch, we don't bother building a list, and simply call
> client_check
> > repeatedly within the loop to do the comparison. This seems to me to be
> > functionally equivalent. Since the list is built solely on the result of
> > client_check calls, and the order there doesn't seem to matter, then I
> don't
> > see what information that it could carry that we don't get by just
> calling
> > client_check directly.
>
> Suppose your /etc/exports contains:
>
> /baz   192.168.1.0/24(rw,no_root_squash)
> /baz   192.168.2.0/24(ro,root_squash)
>
> and your host 'foo' has two IP addresses: 192.168.1.10 and
> 192.168.2.10.
>
> Suppose a request comes from 192.168.2.10 to access a file in /baz.
>
> Old code:
>   Kernel asks for "192.168.2.10".
>   This goes to auth_unix_ip (in cache.c) which calls client_compose on
>   that address.  client_compose will return 192.168.2.0/24 so kernel
>   is told
>           192.168.2.10 -> 192.168.2.0/24
>
>   Then kernel asks "how can 192.168.2.0/24 access /baz".
>   This goes to nfsd_export which checks each export and the first (and
>   only) one that matches is 192.168.2.0/24 so it answers
>   "ro,root_squash" as you would hope.
>
> New code:
>   Kernel asks for "192.168.2.10"
>   This goes to auth_unix_ip which calls client_resolve which calls
>   get_reliable_hostbyaddr which returns "foo".  So kernel is told
>      192.168.2.10 -> foo
>
>   Then kernel asks "how can foo access /baz".
>   This goes to nfsd_export which calls gethostbyname on 'foo' getting
>   { "foo", 192.168.1.10, 192.168.2.10} and then calls client_check
>   against each export.  If the order is unchanged from the
>   /etc/exports file, the first match will be
>           /baz 192.168.1.0/24(rw,no_root_squash)
>
>   so that will be returned to the kernel.  Not what you would hope.
>
> Does that make sense?
>
>
> >
> > So I don't see how the patch I proposed would leave us any more
> vulnerable to
> > the situation you describe than what's already in place. The patch I
> proposed
> > *does* remove one vulnerability as well. The situation where my_client
> has
> > a list of hostnames that are no longer valid due to DNS or netgroup
> changes.
>
> I agree that the my_client caching needs to be fixed.
>
> >
> > As you said, neither the rmtab or the kernel cache is an ideal place to
> pull
> > this info. So, my inclincation is to stick with the rmtab, and simply
> have it
> > track what we know is trackable -- mount and unmount calls into mountd.
> I
> > think having false positives is preferable to possibly having some
> mounts
> > that are not reflected at all because they have gone idle.
>
> Ok, how about this as a way forward.
>
> 1/ remove that 'my_client' caching.
> 2/ Remove the updates of rmtab on client upcalls and simply do rmtab
>     updates with hostname (from get_reliable_hostbyaddr) and path name
>     from MOUNT or UMOUNT requests
> 3/ Add -I flag which:
>       passes IP address rather than client_compose name to kernel and
>       adds rmtab entries on kernel upcalls.  It also hard-removes
>       rmtab entries on 'UMOUNT' and flush the kernel cache so that the
>       next access for that host/path causes an upcall.
> 4/ Add a -? flag (haven't chosen a letter yet) which:
>       implies -I, but when asked for a 'DUMP', it calls gethosytbyname
>       on each IP address to ge a hostname.
>
> Then the default would be vaguely usable, and more precise information
> would be available (at a cost).
>
> >
> > Either way, a manpage update is probably also in order to outline the
> folly
> > of depending on showmount -a :-).
>
> Yes, I would happily accept a patch making such a change.
>
> NeilBrown
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share
> your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>

------=_Part_112679_27381761.1165909940005
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

thanks for opening up this mail.<br>this is really my old problem, I used showmount -a to get who is mounted but its not reporting correctly. It includes the previous mounts until everything is messed up and you can no longer trust anything. I hope this can be improved at least. :-)
<br>I would prefer IP address than hostnames.<br><br>warren<br><br><div><span class="gmail_quote">On 12/12/06, <b class="gmail_sendername">Neil Brown</b> &lt;<a href="mailto:neilb@suse.de">neilb@suse.de</a>&gt; wrote:</span>
<blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">On Sunday December 10, <a href="mailto:jlayton@redhat.com">jlayton@redhat.com</a> wrote:<br>
&gt; Neil Brown wrote:<br>&gt;&nbsp;&nbsp;&gt; So I'm not happy with any patch that removes client_compose and<br>&gt;&nbsp;&nbsp;&gt; client_member in favour of client_resolve.<br>&gt;&nbsp;&nbsp;&gt;<br>&gt;<br>&gt; Here's where I'm confused. I don't see how the patch I proposed loses any
<br>&gt; information:<br>&gt;<br>&gt; In the old method, we get an IP address and we build a list of client<br>&gt; hostnames (in no particular order), using repeated calls to the client_check<br>&gt; function. We then roll through the list of exports and make repeated
<br>&gt; calls to client_member to compare the m_client of the export against the<br>&gt; list. If it doesn't match, we go to the next export.<br>&gt;<br>&gt; With my patch, we don't bother building a list, and simply call client_check
<br>&gt; repeatedly within the loop to do the comparison. This seems to me to be<br>&gt; functionally equivalent. Since the list is built solely on the result of<br>&gt; client_check calls, and the order there doesn't seem to matter, then I don't
<br>&gt; see what information that it could carry that we don't get by just calling<br>&gt; client_check directly.<br><br>Suppose your /etc/exports contains:<br><br>/baz&nbsp;&nbsp; <a href="http://192.168.1.0/24(rw,no_root_squash)">
192.168.1.0/24(rw,no_root_squash)</a><br>/baz&nbsp;&nbsp; <a href="http://192.168.2.0/24(ro,root_squash)">192.168.2.0/24(ro,root_squash)</a><br><br>and your host 'foo' has two IP addresses: <a href="http://192.168.1.10">192.168.1.10
</a> and<br><a href="http://192.168.2.10">192.168.2.10</a>.<br><br>Suppose a request comes from <a href="http://192.168.2.10">192.168.2.10</a> to access a file in /baz.<br><br>Old code:<br>&nbsp;&nbsp;Kernel asks for &quot;<a href="http://192.168.2.10">
192.168.2.10</a>&quot;.<br>&nbsp;&nbsp;This goes to auth_unix_ip (in cache.c) which calls client_compose on<br>&nbsp;&nbsp;that address.&nbsp;&nbsp;client_compose will return <a href="http://192.168.2.0/24">192.168.2.0/24</a> so kernel<br>&nbsp;&nbsp;is told<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://192.168.2.10">192.168.2.10</a> -&gt; <a href="http://192.168.2.0/24">192.168.2.0/24</a><br><br>&nbsp;&nbsp;Then kernel asks &quot;how can <a href="http://192.168.2.0/24">192.168.2.0/24</a> access /baz&quot;.
<br>&nbsp;&nbsp;This goes to nfsd_export which checks each export and the first (and<br>&nbsp;&nbsp;only) one that matches is <a href="http://192.168.2.0/24">192.168.2.0/24</a> so it answers<br>&nbsp;&nbsp;&quot;ro,root_squash&quot; as you would hope.
<br><br>New code:<br>&nbsp;&nbsp;Kernel asks for &quot;<a href="http://192.168.2.10">192.168.2.10</a>&quot;<br>&nbsp;&nbsp;This goes to auth_unix_ip which calls client_resolve which calls<br>&nbsp;&nbsp;get_reliable_hostbyaddr which returns &quot;foo&quot;.&nbsp;&nbsp;So kernel is told
<br>&nbsp;&nbsp;&nbsp;&nbsp; <a href="http://192.168.2.10">192.168.2.10</a> -&gt; foo<br><br>&nbsp;&nbsp;Then kernel asks &quot;how can foo access /baz&quot;.<br>&nbsp;&nbsp;This goes to nfsd_export which calls gethostbyname on 'foo' getting<br>&nbsp;&nbsp;{ &quot;foo&quot;, 
<a href="http://192.168.1.10">192.168.1.10</a>, <a href="http://192.168.2.10">192.168.2.10</a>} and then calls client_check<br>&nbsp;&nbsp;against each export.&nbsp;&nbsp;If the order is unchanged from the<br>&nbsp;&nbsp;/etc/exports file, the first match will be
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/baz <a href="http://192.168.1.0/24(rw,no_root_squash)">192.168.1.0/24(rw,no_root_squash)</a><br><br>&nbsp;&nbsp;so that will be returned to the kernel.&nbsp;&nbsp;Not what you would hope.<br><br>Does that make sense?<br><br><br>
&gt;<br>&gt; So I don't see how the patch I proposed would leave us any more vulnerable to<br>&gt; the situation you describe than what's already in place. The patch I proposed<br>&gt; *does* remove one vulnerability as well. The situation where my_client has
<br>&gt; a list of hostnames that are no longer valid due to DNS or netgroup changes.<br><br>I agree that the my_client caching needs to be fixed.<br><br>&gt;<br>&gt; As you said, neither the rmtab or the kernel cache is an ideal place to pull
<br>&gt; this info. So, my inclincation is to stick with the rmtab, and simply have it<br>&gt; track what we know is trackable -- mount and unmount calls into mountd. I<br>&gt; think having false positives is preferable to possibly having some mounts
<br>&gt; that are not reflected at all because they have gone idle.<br><br>Ok, how about this as a way forward.<br><br> 1/ remove that 'my_client' caching.<br> 2/ Remove the updates of rmtab on client upcalls and simply do rmtab
<br>&nbsp;&nbsp;&nbsp;&nbsp;updates with hostname (from get_reliable_hostbyaddr) and path name<br>&nbsp;&nbsp;&nbsp;&nbsp;from MOUNT or UMOUNT requests<br> 3/ Add -I flag which:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;passes IP address rather than client_compose name to kernel and<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;adds rmtab entries on kernel upcalls.&nbsp;&nbsp;It also hard-removes
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rmtab entries on 'UMOUNT' and flush the kernel cache so that the<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;next access for that host/path causes an upcall.<br> 4/ Add a -? flag (haven't chosen a letter yet) which:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;implies -I, but when asked for a 'DUMP', it calls gethosytbyname
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;on each IP address to ge a hostname.<br><br>Then the default would be vaguely usable, and more precise information<br>would be available (at a cost).<br><br>&gt;<br>&gt; Either way, a manpage update is probably also in order to outline the folly
<br>&gt; of depending on showmount -a :-).<br><br>Yes, I would happily accept a patch making such a change.<br><br>NeilBrown<br><br>-------------------------------------------------------------------------<br>Take Surveys. Earn Cash. Influence the Future of IT
<br>Join SourceForge.net's Techsay panel and you'll get the chance to share your<br>opinions on IT &amp; business topics through brief surveys - and earn cash<br><a href="http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV">
http://www.techsay.com/default.php?page=join.php&amp;p=sourceforge&amp;CID=DEVDEV</a><br>_______________________________________________<br>NFS maillist&nbsp;&nbsp;-&nbsp;&nbsp;<a href="mailto:NFS@lists.sourceforge.net">NFS@lists.sourceforge.net
</a><br><a href="https://lists.sourceforge.net/lists/listinfo/nfs">https://lists.sourceforge.net/lists/listinfo/nfs</a><br></blockquote></div><br>

------=_Part_112679_27381761.1165909940005--


--===============2111144816==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============2111144816==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2111144816==--
