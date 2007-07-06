From: Peter Staubach <staubach@redhat.com>
Subject: Re: 'noacl' NFS parameter seems ineffective (Fedora Core 7)
Date: Fri, 06 Jul 2007 09:40:41 -0400
Message-ID: <468E4659.8090209@redhat.com>
References: <a90f74cc0707051401p38167340s955be299a807710d@mail.gmail.com>	
	<468D6064.3080307@redhat.com>
	<1183728245.6463.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I6o3G-00065l-BL
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 06:40:51 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I6o3I-0004Az-NE
	for nfs@lists.sourceforge.net; Fri, 06 Jul 2007 06:40:54 -0700
In-Reply-To: <1183728245.6463.17.camel@heimdal.trondhjem.org>
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

Trond Myklebust wrote:
> On Thu, 2007-07-05 at 17:19 -0400, Peter Staubach wrote:
>   
>> Actually, all that the "noacl" mount option means is to not attempt
>> to get or set or ACLs on the server.  It does not affect the security
>> checking that the client does to verify access.
>>
>> The permission bits are not enough to determine access permissions.
>> Root mapping on the server is an easy example of this.  Therefore,
>> the client always goes over the wire to query the server for the
>> permissions that it will allow.
>>     
>
> Right. The confusion here stems from the fact that SuSE attempted to
> make "noacl" mean both "I will not get/set any posix acls" and "there
> are no acls on the server" in their kernels.
>
> The common practice of root mapping blows that argument right out of the
> water, and so I never applied the parts of their ACL patches that switch
> off ACCESS calls.

Yes, I think that RHEL-4 had that bug too, at least for a while.  (I hope
only for a while... :-) )

It was misguided on someone's part to think that no ACLs meant that
checking the mode bits for permissions was sufficient.

    Thanx...

       ps


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
