From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 002 of 2] Avoid flush-when-locking
 when	interclient consistency not needed.
Date: Sun, 15 Apr 2007 21:49:08 -0400
Message-ID: <4622D614.5030500@oracle.com>
References: <20070306163710.8128.patches@notabene>
	<1070306054029.8360@suse.de>	<1173192029.6393.52.camel@heimdal.trondhjem.org>	<17903.17597.832563.922428@notabene.brown>
	<1176589265.6089.20.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040306010703040706090709"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdGLn-00015l-Jj
	for nfs@lists.sourceforge.net; Sun, 15 Apr 2007 18:49:51 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HdGLp-0007DL-SW
	for nfs@lists.sourceforge.net; Sun, 15 Apr 2007 18:49:54 -0700
In-Reply-To: <1176589265.6089.20.camel@heimdal.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------040306010703040706090709
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2007-03-08 at 10:03 +1100, Neil Brown wrote:
>>> You can argue for or against the need to invalidate caches when the user
>>> has specified "nolock" (it might be nice to add a Solaris-style "llock"
>>> alias to this one day, btw: nolock == local locking != no locking at
>>> all). We used to do this in early 2.4.x kernels, but that was changed.
>>> The reason is that locking is the only way of ensuring that the NFS
>>> cache is in sync with the server, and the "nolock" exception was
>>> breaking this.

Why not create a special fcntl for NFS files that invalidates cached 
data for that file?  That way, no matter what semantics a lock or unlock 
operation has, there is always a well-defined way to flush the page cache.

>> Yes, the name "nolock" does seem to have been unfortunate.  We had one
>> customer wondering why it wasn't producing an 'ENOLCK' error status.
>> We could create an alias.  "nonlm"?
> 
> I'd prefer "llock", simply because that mirrors the same option on
> Solaris.
> 
>> If you have chosen nocto,nolock, I cannot see any justification in
>> expecting any way of ensuring  the NFS cache is in sync with the
>> server except at unmount.
>>
>> However if you don't like it, that's fine.  It was just a "this might
>> be useful, what do you think" rather than "this is important".  The
>> other patch of the two was the real bugfix.  Did that pass muster?
>>
>> But I worry about adding an 'llock' option that was different from
>> 'nolock'.  How would you explain the difference in a way that didn't
>> confuse people?
> 
> Are we sure that 'llock' differs from 'nolock'? If Chuck is right, then
> we could simply make 'llock' set both the 'nolock' 'nocto' flags, and
> just document that. I'm not sure that he is, though. According to the
> manpage, Solaris documents
> 
>         nocto
>         
>                 No close-to-open consistency.
>         
>         llock
>         
>                 Local locking being used (no lock manager).

We should be careful here.  Solaris, IIRC, has different cache coherency 
semantics from Linux when a file is locked, so it might be difficult to 
compare mount options directly between Linux and Solaris.

Locked NFS files on Solaris get uncached I/O limited to 8KB.  I don't 
know exactly how llock changes this, but I suspect it probably doesn't 
change it at all.  Perhaps someone with Solaris NFS development 
experience can shed some light.

IMO an llock mount option is sorely missing on Linux... and I think it 
should disable the "automatic" cache flushing behaviors as well.  When 
local locking is used, clearly cache coherency with other clients isn't 
needed, and therefore invalidate-on-lock and flush-on-unlock semantics 
are not necessary and serve only to slow things down.

I don't necessarily disagree with Trond about requiring some mechanism 
for cache invalidation to be available.  However, as an aside, if the 
NFS cache invalidation logic is working overall, it really shouldn't 
ever be necessary for applications to trigger invalidation by hand.

--------------040306010703040706090709
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRvdCBj
b20NCnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2
MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQN
Cg0K
--------------040306010703040706090709
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040306010703040706090709
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040306010703040706090709--
