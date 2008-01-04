From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 11:07:45 +0200
Message-ID: <477DF761.8040306@panasas.com>
References: <477CD231.30603@garzik.org>
	<20080103163200.GB30029@fieldses.org>	<477DC501.3060104@garzik.org>
	<477DD11B.40909@melbourne.sgi.com> <477DDA86.6020100@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <477DDA86.6020100@garzik.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan. 04, 2008, 9:04 +0200, Jeff Garzik <jeff@garzik.org> wrote:
>>> I really wish the entire wire protocol were scrapped and replaced with 
>>> something more sane, and easier to parse. 
>> You had me worried there for a moment, I thought you might be the first
>> person to admit to liking the NFS4 protocol design.
>>
>>> It's tempting to see what would arise from a clean-slate wire protocol 
>>> effort, something that is otherwise compatible with NFS 4.x operations, 
>>> objects, and data model.
> 
> It's more like v4 is a vast relative improvement over prior NFS.  Given 
> the huge number of NFS users and sites, IMO v4 is a huge improvement for 
> Unix file sharing overall.
> 
> But if you are dreaming of a truly clean slate protocol...  I've got a 
> long wish list too :)
> 
> 
>> Much like the old phone system, the primary value of protocols like NFS
>> is the
>> widespread presence of reliable conformant implementations.  Most of the
>> rest of
>> the NFS is problematic.  I would argue that some aspects of the NFS
>> operations,
>> objects, and data model is rather more busted than the XDR encoding.
>>
>> The classic persistent file handles, for example, could be considered a
>> major
>> design flaw.  Firstly it makes the inode# -> dentry lookup a performance
>> path
>> for the underlying filesystem, which it isn't in any local load. 
> 
> Oh, certainly.  I was mainly thinking a replacement of the wire protocol 
> would be an easier step for people to swallow than a new protocol.
> 
> But if you are implying there is enough momentum to simply rewrite NFS 
> from scratch, I'll cheer and help out with coding :)  Or maybe Zach 
> Brown will do it for us with CRFS: 
> http://linux.conf.au/programme/detail?TalkID=247
> 
> A big feature of NFS today is its high Just Works(tm) value (ease of 
> configuration and some minimum level of fault tolerance), so any 
> replacement would need to have similar attributes.
> 
> 
>> Another major flaw is putting the client in control of when unstable data is
>> written to disk, but not providing any way for the client to find out how to
>> do that optimally.
>>
>> Then there's the NFS4 approach to extended attributes.
> 
> Ugh.  Don't get me started.  That's not in my server yet, but I can 
> already see the mess ahead.
> 
> 	Jeff
> 

Jeff, taking into account the amount of effort people and different
organizations have already put into NFSv4 and NFSv4.1 I wish you could
tunnel your inventive energy into making NFSv4.1 better rather than
trying to reinvent NFS/RPC/XDR.

Although It's rather late in the process since the NFSv4 working group
is close to putting the NFSv4.1 Internet-draft up for last
call, we would certainly appreciate more implementation feedback.

Benny
