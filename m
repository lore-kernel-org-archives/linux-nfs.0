From: "William A. (Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd
	and rework gssd and idmapd to use the new xlog logging
	infrastructure.
Date: Fri, 14 Sep 2007 13:12:48 -0400
Message-ID: <89c397150709141012j7a8eaff3ne8683759ac97c31e@mail.gmail.com>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
	<20070911153742.GG13948@fieldses.org>
	<1189530078.12340.28.camel@moss-terrapins.epoch.ncsc.mil>
	<20070911171621.GI13948@fieldses.org>
	<1189532033.12340.43.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1455536912=="
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWEij-0002gy-Tf
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 10:12:46 -0700
Received: from rv-out-0910.google.com ([209.85.198.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IWEin-00063n-AM
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 10:12:50 -0700
Received: by rv-out-0910.google.com with SMTP id g11so2852802rvb
	for <nfs@lists.sourceforge.net>; Fri, 14 Sep 2007 10:12:48 -0700 (PDT)
In-Reply-To: <1189532033.12340.43.camel@moss-terrapins.epoch.ncsc.mil>
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

--===============1455536912==
Content-Type: multipart/alternative;
	boundary="----=_Part_2126_5056890.1189789968799"

------=_Part_2126_5056890.1189789968799
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

netlink uses a lot more resources than the pipe_fs. why do we need a socket
and the network layer to send a message to userland? at the end of the day,
copy_to_user is what is used. pipe_fs gets there with a lot shorter code
path.

there was some effort to generalize pipe_fs and move it from the rpc
directory - it's really no big deal.

-->Andy

On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
>
> On Tue, 2007-09-11 at 13:16 -0400, J. Bruce Fields wrote:
> > On Tue, Sep 11, 2007 at 01:01:18PM -0400, David P. Quigley wrote:
> > > Another question about the code in general. Why is it that idmapd is
> > > using fcntl and user signals to indicate changes to the rpc pipe.
> Isn't
> > > there something else we can use like Inotify or a Netlink socket?
> >
> > When a new nfs client is created, a new directory containing several
> > files (including the upcall pipe) are created.  The dnotify stuff is
> > there so we find out about those new files and directories.  I don't
> > know much about netlink--how would it help us there?
>
> I'm not sure that it would be a big help. It seemes that it is a newer
> method for transporting data between user and kernel space. There is a
> Linux journal article from back in 2005 about them which can be found at
> http://www.linuxjournal.com/article/7356. It could remove a dependency
> on pipefs, however the only question would be which technology has been
> around longer. It would also seem the the method of passing the messages
> up to user space would be different. Instead of each client having a
> separate file you could have idmapd/doimapd listen on one netlink socket
> and messages that come in contain a clientid which the daemon would
> associate with the separate clients internally. Again I'm not sure if it
> is a big help, but rather a different way of thinking about it that I am
> considering.
>
> >
> > I assume Inotify would work, but I don't see any advantage over dnotify.
> > If we didn't leave in some compatability code then it would mean
> > dropping support for pre-inotify kernels, wouldn't it?--could be that
> > there were only a few of those and that nfsv4 wasn't really usable on
> > them anyway (I don't remember), but absent a real motivation to move
> > from dnotify to inotify I'd rather not.
>
> That is a good point. Since I'm working on something that will hopefully
> be in future kernels I think I can make the assumption of having the
> extra features.
>
> >
> > > I am assuming that this is just a result of the code being written
> > > before these things were in place. I was originally starting doimapd
> > > based on the idmapd source however if it is acceptable to move to one
> > > of these other techniques I can switched over to that instead.
> >
> > For new stuff I don't think there'd be a problem using something else.
> >
> > --b.
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>
>

------=_Part_2126_5056890.1189789968799
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

netlink uses a lot more resources than the pipe_fs. why do we need a socket and the network layer to send a message to userland? at the end of the day, copy_to_user is what is used. pipe_fs gets there with a lot shorter code path. 
<br><br>there was some effort to generalize pipe_fs and move it from the rpc directory - it&#39;s really no big deal.<br><br>--&gt;Andy<br><br><div><span class="gmail_quote">On 9/11/07, <b class="gmail_sendername">David P. Quigley
</b> &lt;<a href="mailto:dpquigl@tycho.nsa.gov">dpquigl@tycho.nsa.gov</a>&gt; wrote:</span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">On Tue, 2007-09-11 at 13:16 -0400, J. Bruce Fields wrote:
<br>&gt; On Tue, Sep 11, 2007 at 01:01:18PM -0400, David P. Quigley wrote:<br>&gt; &gt; Another question about the code in general. Why is it that idmapd is<br>&gt; &gt; using fcntl and user signals to indicate changes to the rpc pipe. Isn&#39;t
<br>&gt; &gt; there something else we can use like Inotify or a Netlink socket?<br>&gt;<br>&gt; When a new nfs client is created, a new directory containing several<br>&gt; files (including the upcall pipe) are created.&nbsp;&nbsp;The dnotify stuff is
<br>&gt; there so we find out about those new files and directories.&nbsp;&nbsp;I don&#39;t<br>&gt; know much about netlink--how would it help us there?<br><br>I&#39;m not sure that it would be a big help. It seemes that it is a newer
<br>method for transporting data between user and kernel space. There is a<br>Linux journal article from back in 2005 about them which can be found at<br><a href="http://www.linuxjournal.com/article/7356">http://www.linuxjournal.com/article/7356
</a>. It could remove a dependency<br>on pipefs, however the only question would be which technology has been<br>around longer. It would also seem the the method of passing the messages<br>up to user space would be different. Instead of each client having a
<br>separate file you could have idmapd/doimapd listen on one netlink socket<br>and messages that come in contain a clientid which the daemon would<br>associate with the separate clients internally. Again I&#39;m not sure if it
<br>is a big help, but rather a different way of thinking about it that I am<br>considering.<br><br>&gt;<br>&gt; I assume Inotify would work, but I don&#39;t see any advantage over dnotify.<br>&gt; If we didn&#39;t leave in some compatability code then it would mean
<br>&gt; dropping support for pre-inotify kernels, wouldn&#39;t it?--could be that<br>&gt; there were only a few of those and that nfsv4 wasn&#39;t really usable on<br>&gt; them anyway (I don&#39;t remember), but absent a real motivation to move
<br>&gt; from dnotify to inotify I&#39;d rather not.<br><br>That is a good point. Since I&#39;m working on something that will hopefully<br>be in future kernels I think I can make the assumption of having the<br>extra features.
<br><br>&gt;<br>&gt; &gt; I am assuming that this is just a result of the code being written<br>&gt; &gt; before these things were in place. I was originally starting doimapd<br>&gt; &gt; based on the idmapd source however if it is acceptable to move to one
<br>&gt; &gt; of these other techniques I can switched over to that instead.<br>&gt;<br>&gt; For new stuff I don&#39;t think there&#39;d be a problem using something else.<br>&gt;<br>&gt; --b.<br><br>_______________________________________________
<br>NFSv4 mailing list<br><a href="mailto:NFSv4@linux-nfs.org">NFSv4@linux-nfs.org</a><br><a href="http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4">http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4</a><br><br></blockquote>
</div><br>

------=_Part_2126_5056890.1189789968799--


--===============1455536912==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1455536912==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1455536912==--
