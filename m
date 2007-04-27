From: Peter Staubach <staubach@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Fri, 27 Apr 2007 13:34:12 -0400
Message-ID: <46323414.7050403@redhat.com>
References: <17958.48121.280256.493824@notabene.brown>	<200704270820.19718.olaf.kirch@oracle.com>	<46320251.8050900@redhat.com>
	<200704271904.59816.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhUKw-0004kr-6S
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:34:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhUKy-0000fx-Hu
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:34:28 -0700
In-Reply-To: <200704271904.59816.olaf.kirch@oracle.com>
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

Olaf Kirch wrote:
> On Friday 27 April 2007 16:01, Peter Staubach wrote:
>   
>> There isn't a clear cut right answer, but the described behavior is
>> at least definitive.  There were a _lot_ of discussions inside of
>> Sun, comp.protocols.nfs, and at Connectathons regarding this issue,
>> without clear resolutions that were better than the current behavior.
>>     
>
> At least authunix_create should return NULL, not make the
> application die with SIGABRT.
>
> Yes, authentication may fail, but it's better to try and
> fail than give up without trying.
>
>   

Here, we are probably just going to have to agree to disagree, since
I don't agree and I don't think that this is the place to hold that
discussion, again.  :-)


> [...]
>   
>> This version of the library may or may not be MT-safe, but newer
>> versions are definitely safe.  Perhaps the Bull people could tell
>> us how old the library is?
>>     
> [...]
>   
>> Here is a place where a newer version of the TI-RPC library would help.
>>     
> [...]
>   
>> Yup, that was a bug, and has already been fixed in a newer version of the
>> library.
>>     
> [...]
>   
>> This seems like another bug that is already fixed in newer versions of
>> TI-RPC.
>>     
> [...]
>   
>> This seems like a porting issue to me.  Thank you for pointing it
>> out so that it can get addressed.
>>     
>
> You see why I'm arguing against just replacing working code
> with something else, without understanding the ramifications?
>
>   

Well, I don't quite think that it is that black and white.  Sometimes,
changes like this one will prove to be, can affect functionality.

> Seems like at least it's time for a mor recent tirpc version.
>
>   

Yes, definitely.  :-)

>>> That's where we disagree :-) I think ripping out the glibc
>>> code and replacing it will cause a lot of maintenance for
>>> the distros.
>>>       
>> I am curious what basis that you are using for this?  Why will this
>> cause either more or less maintenance for distros?
>>     
>
> I admit this is not founded on anything quantifiable. Let's say
> based on experience, if you replace 22,000 lines of code used
> heavily by almost everyone, there's going to be considerable
> churn. If you just rip out the getgroups change in glibc and
> go back to the abort() behavior we discsussed above, I'd bet
> there will be level3 support calls at $your_favorite_linux_vendor
> that force you to put that code back in.
>
>   

Maybe.  I also wouldn't be surprised if no one noticed for quite
some time too.

>> It seems to me that this would give us some RPC code, which we could
>> support, which was newer than the current glibc code, and would have
>> more people working on and supporting it.  That all seems like goodness
>> to me.  The current situation is that we can't maintain the RPC code
>> at all, which is not goodness at all.
>>     
>
> I'm all for forking the sunrpc code. I'm just not convinced that
> it is a good idea to replace code that is arguably stable with
> something else which may have been tested on Solaris but not
> on Linux.

I am one of those who believe that there finally comes a time
to cut the past loose and move forward with a whole new code base.
This sort of decision must be made carefully, but continuing to
hack and kludge on the same old code, just for the sake of the
perception that doing so won't impact existing users, always just
ends up being false and those users get impacted.

Change is not something to be afraid of.  It is healthy and as
long as we make intelligent decisions, based on as much information
as we can get, we will be fine and our users will be pleased with us.

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
