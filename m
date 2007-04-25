From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect	sub-second
 timestamps on etab
Date: Wed, 25 Apr 2007 17:29:52 -0400
Message-ID: <462FC850.7040600@oracle.com>
References: <20070425173918.GB6696@salusa.poochiereds.net>	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010701020302060209050007"
Cc: nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgp5Y-0000sz-5Y
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 14:31:49 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hgp5Z-0006XE-FX
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 14:31:50 -0700
In-Reply-To: <20070425201354.GD6696@salusa.poochiereds.net>
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
--------------010701020302060209050007
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Layton wrote:
> On Wed, Apr 25, 2007 at 02:09:34PM -0400, Jeff Layton wrote:
>> On Wed, Apr 25, 2007 at 01:39:20PM -0400, Jeff Layton wrote:
>>> Currently, when auth_reload is called, it only looks at the tv_sec field
>>> of the mtime when deciding whether to invalidate the exports cache. It's
>>> fairly simple to fool this by doing something like:
>>>
>>> # exportfs -rv && rpc.mountd && exportfs -uva && exportfs -iv -o no_root_squash,rw 127.0.0.1:/foo
>>>
>>> With this, exportfs will show the export for /foo, but mountd will still have
>>> whatever contents were in /etc/exports. The issue is that the etab is being
>>> updated twice during the same second, and mountd is reading in the file in
>>> between updates. When it goes to look at the file again, its timestamp matches
>>> the timestamp of the cache, and it ends up keeping the cached contents even
>>> though the file has changed.
>>>
>>> While not all local filesystems provide sub-second timestamps, we might as
>>> well fix this problem on those that do. The following patch changes
>>> auth_reload to consider the tv_nsec field of the mtime when deciding whether
>>> to invalidate the export cache. It also fixes up the callers to pass it a
>>> pointer to a struct timespec for it to fill out.
>>>
>>> I've not yet tested this on a filesystem that provides sub-second timestamps,
>>> so I'm not clear on how well this works yet, but it seems to not break
>>> anything on ext3 in some cursory testing.
>>>
>> No sooner than I post than I see a (minor) problem. The check for a NULL
>> pointer in auth_reload should be (ts != NULL) instead of (ts). Respun patch
>> follows:
>>
> 
> I tested this on a filesystem that does nanosecond timestamps (xfs), and it
> seems to correct the original problem.

Hi Jeff-

I don't know much about the export logic, but why not use inode change 
notification instead of time stamps?

--------------010701020302060209050007
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck.lever@nospam-oracle.com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------010701020302060209050007
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------010701020302060209050007
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010701020302060209050007--
