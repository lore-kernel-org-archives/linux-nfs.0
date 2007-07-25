From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] NFS: have string-based mount options default to
 "intr" mounts
Date: Wed, 25 Jul 2007 19:51:39 -0400
Message-ID: <20070725195139.e83e6d5f.jlayton@poochiereds.net>
References: <20070725145614.e17ca721.jlayton@redhat.com>
	<46A7A632.2050900@oracle.com>
	<20070725154107.063c3b9a.jlayton@redhat.com>
	<1185394617.6585.135.camel@localhost>
	<20070725164323.d2cc9212.jlayton@redhat.com>
	<46A7BB83.1000106@redhat.com>
	<20070725194806.d98436b0.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDqds-0006JS-7S
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 16:51:44 -0700
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IDqdv-00021v-Or
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 16:51:48 -0700
In-Reply-To: <20070725194806.d98436b0.jlayton@redhat.com>
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

On Wed, 25 Jul 2007 19:48:06 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 25 Jul 2007 17:07:15 -0400
> Peter Staubach <staubach@redhat.com> wrote:
> 
> > Jeff Layton wrote:
> > > On Wed, 25 Jul 2007 16:16:57 -0400
> > > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > >
> > >   
> > >> On Wed, 2007-07-25 at 15:41 -0400, Jeff Layton wrote:
> > >>     
> > >>> On Wed, 25 Jul 2007 15:36:18 -0400
> > >>> Chuck Lever <chuck.lever@oracle.com> wrote:
> > >>>
> > >>>       
> > >>>> I thought "nointr" was the default because it is safest.
> > >>>>
> > >>>>         
> > >>> I could see maybe with soft mounts, but in conjunction with a hard
> > >>> mount (which is the default) is there danger of corruption?
> > >>>       
> > >> You may cause the sync to disk on close() to be aborted. The writes will
> > >> eventually get flushed to disk by the flushd() daemon, but failing to
> > >> sync writes to disk prior to closing the file is a violation of
> > >> close-to-open caching semantics and may cause corruption issues.
> > >>
> > >> Trond
> > >>
> > >>     
> > >
> > > The close would return EINTR in this case though, wouldn't it? The app
> > > should then be aware that it didn't actually happen and should
> > > reattempt it. Presuming that the app handles this correctly, is it
> > > really a data corruption issue?
> > 
> > You can't retry the operation.  Even if close() returns an error,
> > the file descriptor is really closed.
> > 
> 
> Interesting. The close(2) manpage is unclear on this on this point.
> 
> > But, the application can take some other form of error recovery.
> > 
> > ----
> > 
> > I think that I object the data corruption characterization.  The
> > data doesn't become corrupted.  It, eventually, is written out to
> > stable storage.  However, an application which concerned with
> > consistency needs to be able to do something valid when a close
> > operation returns an error, whether it is EINTR or something else.
> > 
> 
> That's my thinking too, though if you close and get an error, it's
> not clear to me what that should be. There doesn't seem to be a way to
> block waiting for the data to be flushed out. If the fd is closed, I
> suppose you would have released any locks you have. Other machines
> would be able to get in there before your data gets flushed to the
> server.
> 
> Now that I think about it, I guess we have similar issues with nointr
> if the server reboots at just the wrong time during a close call too.
> 

Actually, this is probably not correct. I was thinking that if the
server rebooted during a commit call issued on a close then the app
would need to reissue the writes. I don't think this is the case
though...

> In any case, I guess the question here is "what should the default be"?
> Currently, it's nointr for nfs2/3 and intr for nfs4. If you use
> string-based options, it's nointr everywhere. I think we ought to try to
> make it consistent unless there's good reason not to. We should also
> make sure the nfs manpage is correct.
> 
> --
> Jeff Layton <jlayton@redhat.com>
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-- 
Jeff Layton <jlayton@poochiereds.net>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
