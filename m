From: Peter Staubach <staubach@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Fri, 27 Apr 2007 13:06:38 -0400
Message-ID: <46322D9E.6070707@redhat.com>
References: <17958.48121.280256.493824@notabene.brown>	<200704270820.19718.olaf.kirch@oracle.com>	<46320251.8050900@redhat.com>
	<200704271849.57729.olaf.kirch@oracle.com>
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
	id 1HhTuE-0001uy-KI
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:06:52 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhTuG-000238-VU
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:06:53 -0700
In-Reply-To: <200704271849.57729.olaf.kirch@oracle.com>
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
>> It seems to me that you are still missing the point of the lock.
>>
>> The lock is not being used to protect the assignment of the address
>> of clnt_raw_private to clp, it is being used to ensure that clp is not
>> being used before clnt_raw_private is completely initialized.
>>
>> The lock is also used to ensure that multiple copies of clnt_raw_private
>> are not allocated.
>>     
>
> Are we talking of the same piece of code? Can you explain to me how
> the following, which is  a copy of Bull's TIRPC library, ensures this?
>
> clntraw_create:
>
>         struct clntraw_private *clp = clntraw_private;
> [...]
>
>         mutex_lock(&clntraw_lock);
>         if (clp == NULL) {
>                 clp = (struct clntraw_private *)calloc(1, sizeof (*clp));
>                 if (clp == NULL) {
>                         mutex_unlock(&clntraw_lock);
>                         return NULL;
>                 }
> [...]
>                 clntraw_private = clp;
>         }
>
> Assume 2 threads enter clntraw_create simultaneously,
> and clntraw_private is NULL.
> Both execute clp = clntraw_private, and both see a
> value of  NULL. Thread A grabs the mutex, thread B blocks.
>
> Thread A finds clp == NULL, allocates memory, puts the
> pointer into clntraw_private, does clever stuff and releases the
> mutex.
>
> Thread B wakes up, acquires the mutex. It checks
> clp, which is still NULL, and allocates another
> private object.
>
> I really do think I understand the code, and there is
> a problem. The mutex protects the clntraw_private
> pointer, so the only safe thing to do is access that
> variable while holding the lock, *not* before.
>   

You are right, the code snippet above is obviously incorrect.

My apologies, I was looking at two different pieces of code and
commented about one, in response to comments about the other.  I
also hadn't realized that you were talking about clntraw_create
because there are several other instances of pretty much the
same construct in other places in the same file.

The newer versions of the TI-RPC support have this bug fixed.
Plus, they use the global variable, clnt_raw_private, instead of
clntraw_private.  (That's why I changed the name in my response...)

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
