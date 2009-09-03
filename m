From: Steve French <smfrench@gmail.com>
Subject: Re: POSIX ACL support for NFSV4 (using sideband protocol)
Date: Thu, 3 Sep 2009 08:57:21 -0500
Message-ID: <524f69650909030657y31e71c19v874772d67d1650df@mail.gmail.com>
References: <4A9F6027.9050807@s3group.cz>
	<7A24DF798E223B4C9864E8F92E8C93EC03F0ABED@SACMVEXC1-PRD.hq.netapp.com>
	<524f69650909030636g68706b09wa50ad91984407878@mail.gmail.com>
	<20090903135404.GA4566@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: linux-nfs@vger.kernel.org, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	nfsv4@linux-nfs.org, ffilzlnx@linux.vnet.ibm.com, jra@samba.org,
	agruen@suse.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090903135404.GA4566@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 3, 2009 at 8:54 AM, J. Bruce Fields<bfields@fieldses.org> wrote:
> On Thu, Sep 03, 2009 at 08:36:44AM -0500, Steve French wrote:
>> On Thu, Sep 3, 2009 at 2:46 AM, Muntz, Daniel<Dan.Muntz@netapp.com> wrot=
e:
>> > I've always thought of NFS as a means for making physical file systems
>> > available across a network. =A0NFS having its own ACLs doesn't fit this
>> > model. =A0E.g., "NFS ACLs" will never be integrated into NTFS. =A0Howe=
ver, I
>> > could imagine NFS ACLs solving the general problem if they were to form
>> > a superset of the ACLs of exportable physical file systems
>>
>> NFSv4 ACLs are similar to CIFS/NTFS ACLS. NFSv4 ACLs were
>> originally based on CIFS/NTFS ACLs so it would be reasonable
>> to export them from NTFS (although the SIDs (UUIDs) have to be mapped
>> to local Linux UIDs - we have user space code that can do this in Samba).
>
> On the server side, you'd actually have to map between SIDs and NFSv4
> names (strings of the form user@domain).

Yes ... We could add mapping directly from user@domain to SID - Samba
has something similar,
but we already have both mapping to/from unix uid.

1) SID (UUID, a number) to/from a local Unix UID (which winbind and
others have today)
and
2) user@domain mapped to/from local Unix UID (which NFS user space
code has today)

If


-- =

Thanks,

Steve
