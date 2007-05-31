From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH 02/10] NFS: Use C99 struct initializers in
	nfs4proc.c
Date: Thu, 31 May 2007 14:19:47 +0200
Message-ID: <20070531121947.GA26565@janus>
References: <20070525214105.28668.75496.stgit@schiele.1015granger.net>
	<1180202462.5517.8.camel@heimdal.trondhjem.org>
	<465C3459.7010302@oracle.com>
	<1180555947.6770.53.camel@heimdal.trondhjem.org>
	<20070531081803.GA24538@janus>
	<1180613931.6696.36.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Htjd7-0003ex-1Q
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 05:19:49 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Htjd8-000115-UO
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 05:19:51 -0700
In-Reply-To: <1180613931.6696.36.camel@heimdal.trondhjem.org>
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

On Thu, May 31, 2007 at 08:18:51AM -0400, Trond Myklebust wrote:
> On Thu, 2007-05-31 at 10:18 +0200, Frank van Maarseveen wrote:
> > On Wed, May 30, 2007 at 04:12:27PM -0400, Trond Myklebust wrote:
> > > On Tue, 2007-05-29 at 10:10 -0400, Chuck Lever wrote:
> > > > Trond Myklebust wrote:
> > > > > On Fri, 2007-05-25 at 17:41 -0400, Chuck Lever wrote:
> > > > >> Follow kernel coding conventions.
> > > > >>
> > > > >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > > > >> ---
> > > > >>
> > > > >>  fs/nfs/nfs4_fs.h  |    5 ++++
> > > > >>  fs/nfs/nfs4proc.c |   70 ++++++++++++++++++++++++++++-------------------------
> > > > >>  2 files changed, 42 insertions(+), 33 deletions(-)
> > > > >>
> > > > >> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> > > > >> index cf3a17e..1a526c4 100644
> > > > >> --- a/fs/nfs/nfs4_fs.h
> > > > >> +++ b/fs/nfs/nfs4_fs.h
> > > > >> @@ -145,6 +145,11 @@ struct nfs4_exception {
> > > > >>  	int retry;
> > > > >>  };
> > > > >>  
> > > > >> +#define DECLARE_NFS4_EXCEPTION(name)				\
> > > > >> +	struct nfs4_exception name = {				\
> > > > >> +		.timeout	= 0,				\
> > > > >> +	}
> > > > > 
> > > > > Why would we want this? The existing code uses bog standard C99
> > > > > initialisers. There is no need to explicitly set .timeout to zero.
> > > > 
> > > > Using
> > > > 
> > > >    struct nfs4_exception name = { };
> > > > 
> > > > causes compiler complaints.  One correct way to fix this is to set at 
> > > > least one field in the structure, and setting that field to zero clears 
> > > > the other one by default.
> > > 
> > > I can't find anything in Harbison & Steele stating that name = {} is
> > > illegal. All they say is that "if there are fewer initializers than
> > > there are structure components, the remaining components are initialized
> > > to their default initial values.".
> > 
> > AFAIK and I checked ISO/IEC 9899:1999 to be sure, {initializer-list}
> > cannot be empty according to the C syntax.
> 
> but a trivial initialiser like "name = {0}" is, right?

yes.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
