From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [NFS] NFS readonly failover and linux?
Date: Tue, 1 Feb 2005 15:08:00 -0500
Message-ID: <16895.57760.531261.8465@segfault.boston.redhat.com>
References: <1106871309.6181.254.camel@seki.nac.uci.edu>
	<Pine.LNX.4.61.0501291127450.1607@donald.themaw.net>
	<1107205302.4071.17.camel@seki.nac.uci.edu>
	<Pine.LNX.4.58.0502010945400.25875@wombat.indigo.net.au>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: autofs mailing list <autofs@linux.kernel.org>,
        Dan Stromberg <strombrg@dcs.nac.uci.edu>, nfs@lists.sourceforge.net
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.58.0502010945400.25875@wombat.indigo.net.au>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

==> Regarding Re: [NFS] NFS readonly failover and linux?; Ian Kent <raven@themaw.net> adds:

raven> On Mon, 31 Jan 2005, Dan Stromberg wrote:
>> On Sat, 2005-01-29 at 11:46 +0800, raven@themaw.net wrote: > On Thu, 27
>> Jan 2005, Dan Stromberg wrote:
>> > 
>> > >
>> > > The autofs man pages on Redhat Enterprise Linux 3 as well as Fedora
>> Core > > 3 both say that autofs supports replicated, readonly fileserver
>> failover > > - but then there's a footnote of sorts that says autofs
>> only supports it > > to the extent that mount does.
>> > 
>> > That part of the man page is old and slightly out of date.
>> > 
>> > The reason that this is left there is that autofs cannot support >
>> dynamic failover as it just uses mount. However, a different host may be
>> > selected at mount, after a previous timeout, for example. The issue of
>> > umounting existing mounts from servers that have gone away is not >
>> explicitly dealt with yet.
>> 
>> I see.
>> 
>> > >
>> > > Upon trying to do such a mount, I get:
>> > >
>> > > seki-root> mount > >
>> dcslib1.nacs.uci.edu,dcslib4.nacs.uci.edu:/dcspdb/rhel-3-i686 /mnt/nfs >
>> > mount: warning: multiple hostnames not supported > > Thu Jan 27
>> 16:12:18
>> 
>> > What version of autofs are you using?  > The autofs replicated server
>> code is still relatively new.

raven> But, as we know, mount doesn't know about multiple host
raven> names. autofs breaks these out.

So what is the actual problem, here?  Are you using the automounter?  What
do your config files look like?

>> FC3: autofs-4.1.3-28 RHEL3: autofs-4.1.3-47

raven> I believe that the replicated server code should be present in both
raven> of these.

raven> Can you confirm please Jeff?

raven> Perhaps you are seeing a bug which needs to be addressed.

Yes, the replicated server code is present in both of these versions.

>> The FC3 is yum update'd fairly regulary, and the RHEL3 is up2date'd
>> regularly as well.
>> 
>> > If your autofs supports replicated server map entries then multiple >
>> host mount requests will not reach the mount command.
>> 
>> Interesting.
>> 
>> > If you are using a RedHat based distro then check >
>> http://people.redhat.com/jmoyer > for the latest patched versions
>> > 
>> > Also, you may need a kernel patch depending on your kernel
>> version. See > README.patches in the distribution or join the autofs
>> list at > http://linux.kernel.org/mailman/listinfo/autofs
>> 
>> I'm certain my management will only go for this, in the short term, if
>> it works on a mainstream RHEL3 system.  Unfortunately, for me, the rest
>> is academic interest.

raven> Once again I believe that the kernels mentioned here are up to date
raven> wrt autofs.

raven> Certainly, the latest FC3 kernel is at 2.6.10 which has all the
raven> autofs4 updates included in the base kernel.

raven> I believe the latest update to RHEL3 is also up to date. Jeff?

Yes, both kernels have the necessary patches to support replicated server.

raven> So perhaps you could send a log trace with the "--debug" option
raven> added to the master map entry.

And please include the contents of your maps!

-Jeff
