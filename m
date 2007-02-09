From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 03/12] Extend the exportfs interface to pass
	fslocations info into the kernel.
Date: Fri, 9 Feb 2007 09:19:44 -0500
Message-ID: <4d569c330702090619m1ddb8c2j5068d454f27051d4@mail.gmail.com>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
	<20070208222704.23464.86120.stgit@rock.citi.umich.edu>
	<17867.49873.883604.237104@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Fredric Isaman <iisaman@citi.umich.edu>,
	nfs@lists.sourceforge.net
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFWbH-00058l-P2
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 06:19:43 -0800
Received: from ug-out-1314.google.com ([66.249.92.171])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFWbJ-00053m-Cb
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 06:19:45 -0800
Received: by ug-out-1314.google.com with SMTP id z38so788912ugc
	for <nfs@lists.sourceforge.net>; Fri, 09 Feb 2007 06:19:44 -0800 (PST)
In-Reply-To: <17867.49873.883604.237104@notabene.brown>
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

On 2/8/07, Neil Brown <neilb@suse.de> wrote:
> On Thursday February 8, kwc@citi.umich.edu wrote:
> > From: Kevin Coffman <kwc@citi.umich.edu>
> >
> > Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> > Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> >
> > Extend exportfs interface to pass fslocations info into the kernel,
> > using syntax modelled after AIX.  Adds "--refer" and "--replicas"
> > options to exportfs to enable use of the kernel fslocation code.
>
> I cannot see the "--refer" and "--replicas" implemented or documented
> in the patch.  I think the changelog entry must be out of date, and
> when we remove that sentence, there isn't much left....

I guess that should read "refer=" and "replicas=".

> > +/* Called by setting 'Method = stub' in config file.  Just returns
> > + * some syntactically correct gibberish for testing purposes.
> > + */
> > +static struct servers *method_stub(char *key)
> > +{
> > +     struct servers *sp;
> > +     struct mount_point *mp;
> > +
> > +     syslog(LOG_INFO, "called method_stub");
> > +     sp = malloc(sizeof(struct servers));
> > +     if (!sp)
> > +             return NULL;
> > +     mp = calloc(1, sizeof(struct mount_point));
> > +     if (!mp) {
> > +             free(sp);
> > +             return NULL;
> > +     }
> > +     sp->h_num = 1;
> > +     sp->h_mp[0] = mp;
> > +     mp->h_host = strdup("stub_server");
> > +     mp->h_path = strdup("/my/test/path");
> > +     sp->h_referral = 1;
> > +     return sp;
> > +}
>
>
> This makes perfect sense for testing during development, but do you
> really want it in the released version?
> If so, should there be "#ifdef DEBUG" or something around it ??

Sounds reasonable.

> And I'm a little confused by the replicas_lookup, method_list stuff.
> I think it is just parsing the format from /etc/exports so that it can
> be written in the different format to the kernel.
> It would seem more appropriate to do this when parsing the
> /etc/exports (to /etab) file rather than every time we talk to the
> kernel.  Is there are reason for the way it is?
> (Just trying to make sure I understand).

I'll have to defer to Fred on this.  I think he is going to be out for a week.

K.C.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
