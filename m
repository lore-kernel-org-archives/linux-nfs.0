From: Peter Staubach <staubach@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Fri, 27 Apr 2007 10:21:08 -0400
Message-ID: <463206D4.9050504@redhat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251056.03664.olaf.kirch@oracle.com>
	<46312615.2090307@RedHat.com>
	<200704270820.19718.olaf.kirch@oracle.com>
	<46320251.8050900@redhat.com> <20070427140931.GA9998@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhRK5-0000zc-AU
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:21:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhRK5-0006mZ-Lf
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:21:24 -0700
In-Reply-To: <20070427140931.GA9998@infradead.org>
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

Christoph Hellwig wrote:
> On Fri, Apr 27, 2007 at 10:01:53AM -0400, Peter Staubach wrote:
>   
>> This version of the library may or may not be MT-safe, but newer
>> versions are definitely safe.  Perhaps the Bull people could tell
>> us how old the library is?
>>     
>
> The README file claims it's a Sun codedrop from 1993 (!)
>
>   

Woof!  There may have been a few bug fixes made since then...  :-)

>>> That's where we disagree :-) I think ripping out the glibc
>>> code and replacing it will cause a lot of maintenance for
>>> the distros.
>>>  
>>>       
>> I am curious what basis that you are using for this?  Why will this
>> cause either more or less maintenance for distros?
>>     
>
> It's the same reason why we tell people to send us incremental
> kernel patches.  Replacing a codebase completely is a not calculateable
> risk.  It might work out just fine, but usually it doesn't because
> something silently breaks.  Updating the existing codebases with
> small bugfixes or new features means you have to think about and justify
> every little understandable change and there's a much higher chance that
> it won't cause problems.  In the end some of them will cause problems
> anyway, but at least you can easily track the problem down to a single
> change now.
>
>   

Yes, I agree with all that.

However, we are also looking at making fairly major changes to the
support already.  I think that the situation will be more complex
than we would ideally like, no matter what we do.  The IPv6 support
is not trivial stuff and will most likely have an impact on the
applications that use RPC no matter what we do.  There are other
things that we can and perhaps should do as well to increase the
usefulness of the support.  I suspect that there are things that
we could do to reduce the number of UDP and TCP ports being used,
for example.

>> It seems to me that this would give us some RPC code, which we could
>> support, which was newer than the current glibc code, and would have
>> more people working on and supporting it.  That all seems like goodness
>> to me.  The current situation is that we can't maintain the RPC code
>> at all, which is not goodness at all.
>>     
>
> I don't think the problem is that we can't maintain it, but rather
> that no one stepped up to maintain it so far.
>   

I had the impression that SteveD had stepped up.  Or am I speaking out of
turn for him?  :-)

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
