Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2A6E4E2F12
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410404; cv=none; b=uEgWzG7dFglxJToLzItM9oID6uZ9WvyimaJYy9Z5ITg5KAA1OTF/yk9Rdba9V7ii8gcoY+uFCgAjFFeT2EUia4ni4IzbmfnZQ2sbqiqyLYroOlWdgoycC8ehcDJz9nN7+P9rbvpriAloESVOH7ej8Crtms3e5N5U5n9w+RiFCxc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410404; c=relaxed/simple;
	bh=HN7h5NWLwFQ8j4PBkGJquhaP1wu9oqnFDePjY3TT87o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=EemBvdjiwumXVkVwV+7s/pZJ6mqCqyrVT99l/Q9RBCrs128p7nZ0EzQ/eCFJ3AYZ472AlEaUjVi2TyT2OYprq6b5+wemNqgzgGi4D4H3X4sl0zmwOA2Eo9oZrHyXmgpgogvI07FKVf4NtGG8OK7vfhYK5eKThR3ISrlbX8Vxq+Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=D6yiyr4X; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="D6yiyr4X"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5F2CF1F000C7;
	Mon, 19 Oct 2026 11:46:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410402;
	bh=atveHfqniLnGgnkqA5uZ1INVcmPrnJ1PvFTnBvzaytA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=D6yiyr4XIzCNZKqDXhGA3uWrfdwUzmM1soQOpGaxBpuXKmFslSoFta0DRegL7/wvJ
	 4P3wX/xdXHlO/aE/DTrNuhhu9XJ+ldSLQBlsDuokbyxuJOO3wqGab2bUcqlK56S2+O
	 iPN3bu+R1g799KWK6q6UoHzTQ/1dwzb//jl9sJY61w8Byvu8bAWnfwFpeRbn5I4bHk
	 CU69q7BR4HPr/menwaMJr6YiFWxm24ttyucvuG11ic0DO9KdgMn1ELmYoxLqZ2tlOt
	 ne9y0LtM+TUryfNH6rDHZ/15HtmTmV97R8XUpfLt3jNEriBWlnhjy+4Xq+wKsj5Rhu
	 djMdb/V9cJGXw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 19 Oct 2026 07:46:27 -0400
Subject: [PATCH nfs-utils v2 7/7] Add MAINTAINERS file and
 get_maintainer.pl
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261019-netlink-noproc-v2-7-7d09a49b574b@kernel.org>
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=20077; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=HN7h5NWLwFQ8j4PBkGJquhaP1wu9oqnFDePjY3TT87o=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMef6kzjiVCs72hXiSA1FWLHpzse0BRT9UdN
 pT79+akS2aJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDHgAKCRAADmhBGVaC
 FbstEACnRit4B0DebBuFGU5ZLUtW7NfEh7C+FOPnbWM6y2p7NHx4L9GDNY/NrQG56TCjqdDcWv8
 juVK3if8QP53GQl7kf43OxyiOjuskKs1G6fj+iXWVTyWwghF7UMTyZVzRYUgvl4JtwjUvm25KGM
 6lheRwIeQSCo+SU5nfNA8iknr7ZAUohN/hVt1UPYnan0FwAeZ3ljSLqu+D7cpMQj9jGnQ5h3oHn
 H4gKOyET2LzlTs4c3dhjJ2+UGc8cNVJrAXo4KTX3v0wtv3N/WG7okFXjjmLh0H6lHD4hlO1MUgA
 XHSk/RuQdjyo3gX33FAQooVnD0QspWx4+wFTXeQpjVeoXUaQPKufhJCMchoapBo4iiOA1qE9Pif
 d+UkgxuJfk2r/VJ9JrmxRMFeY9SS0Fli0VZROC5j1XBVM+8zduJOw0cYBqfnJnHk6qM4cu4XPUJ
 TG8zGQrWxxq4xK1xzOvv/I+tv2WcnjtZs2mkCtsVs7oXX2Io1qINiBOTlAxCEdKFEm/cqHbo3yR
 TJpdWuJht8VUlVp/qBzjeNjepN2zQIpnfhvSby3g7ABXNTCVLbedBlvvYub0F4v46W7+3UErdMn
 3aI4WpwpxLltTKEdnQuZZHS8jnsr+JMnClsuBFyZyu43BFrnMOxcj2qjOZkSU8iFlIcd/JTMyUO
 yB933cqONp64c/g==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

b4 prep --auto-to-cc looks for scripts/get_maintainer.pl at the top of
the tree and runs it to collect To/Cc addresses. Add a kernel-style
MAINTAINERS file plus a minimal get_maintainer.pl that implements the
F/X/N/K match types, ship both in make dist, and cover the b4 flag sets
with a new test.

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 MAINTAINERS                   |  58 +++++++
 Makefile.am                   |   2 +
 scripts/get_maintainer.pl     | 370 ++++++++++++++++++++++++++++++++++++++++++
 tests/Makefile.am             |   2 +-
 tests/t0003-get-maintainer.sh | 140 ++++++++++++++++
 5 files changed, 571 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
new file mode 100644
index 000000000000..1638220f6b71
--- /dev/null
+++ b/MAINTAINERS
@@ -0,0 +1,58 @@
+List of maintainers and how to submit nfs-utils changes
+====================================================
+
+Patches for nfs-utils are reviewed on the linux-nfs mailing list and
+applied by the maintainer.  There is no pull request workflow.
+
+Mailing list: linux-nfs@vger.kernel.org (plain text, inline patches,
+typically with git send-email or b4 send).  Because the list is shared
+with the kernel NFS client and server code, prefix nfs-utils patch
+subjects with [PATCH nfs-utils] so the target tree is obvious.
+
+This file uses the same section format as the Linux kernel MAINTAINERS
+file.  scripts/get_maintainer.pl reads it and prints the people and
+lists to Cc on a patch; "b4 prep --auto-to-cc" runs that script for
+you.  For example:
+
+	scripts/get_maintainer.pl <patch>
+	b4 prep --auto-to-cc
+
+Every patch must carry a Signed-off-by: trailer (Developer's
+Certificate of Origin, as in the kernel).
+
+Descriptions of section entries
+-------------------------------
+
+	M: *Mail* patches to: FullName <address@domain>
+	R: Designated *Reviewer*: FullName <address@domain>
+	   These reviewers should be Cc'd on patches.
+	L: *Mailing list* that is relevant to this area
+	S: *Status*, one of the following:
+	   Supported:	Someone is actually paid to look after this.
+	   Maintained:	Someone actually looks after it.
+	   Odd Fixes:	It has a maintainer but they don't have time to do
+			much other than throw the odd patch in.
+	   Orphan:	No current maintainer.
+	   Obsolete:	Old code, replaced by a better system.
+	T: *SCM* tree type and location.
+	F: *Files* and directories wildcard patterns.
+	   A trailing slash includes all files and subdirectory files.
+	   F:	utils/mountd/	all files in and below utils/mountd
+	   One pattern per line.  Multiple F: lines acceptable.
+	X: *Excluded* files and directories that are NOT maintained, same
+	   rules as F:.  Exclusions are tested before file matches.
+	N: Files and directories *Regex* patterns.
+	   One pattern per line.  Multiple N: lines acceptable.
+	K: *Content regex* (perl extended) pattern match in a patch or file.
+	   One regex pattern per line.  Multiple K: lines acceptable.
+
+Maintainers List
+----------------
+
+NFS-UTILS
+M:	Steve Dickson <steved@redhat.com>
+L:	linux-nfs@vger.kernel.org
+S:	Maintained
+T:	git git://git.linux-nfs.org/projects/steved/nfs-utils.git
+F:	*
+F:	*/
diff --git a/Makefile.am b/Makefile.am
index 72ad4ba7ff42..0c0ed27d71a5 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -8,6 +8,8 @@ MAINTAINERCLEANFILES = Makefile.in
 
 EXTRA_DIST = \
 	autogen.sh \
+	MAINTAINERS \
+	scripts/get_maintainer.pl \
 	\
 	aclocal/bsdsignals.m4 \
 	aclocal/getrandom.m4 \
diff --git a/scripts/get_maintainer.pl b/scripts/get_maintainer.pl
new file mode 100755
index 000000000000..b7c732198353
--- /dev/null
+++ b/scripts/get_maintainer.pl
@@ -0,0 +1,370 @@
+#!/usr/bin/perl
+#
+# scripts/get_maintainer.pl -- report whom to Cc on an nfs-utils patch
+#
+# Copyright (C) 2026  Jeff Layton <jlayton@kernel.org>
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License
+# as published by the Free Software Foundation; either version 2
+# of the License, or (at your option) any later version.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation, Inc.,
+# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+#
+# Reads the MAINTAINERS file at the top of the tree (same section format
+# as the Linux kernel MAINTAINERS file) and prints the matching M:, R:
+# and L: entries for the files in a patch.  This is a deliberately small
+# subset of the kernel scripts/get_maintainer.pl: the F:, X:, N: and K:
+# match types are supported, but there is no git history fallback and no
+# interactive mode.  It understands the option subset that "b4 prep
+# --auto-to-cc" passes, so that command works out of the box:
+#
+#	scripts/get_maintainer.pl <patch>
+#	scripts/get_maintainer.pl -f <file>...
+#	scripts/get_maintainer.pl --self-test
+
+use strict;
+use warnings;
+use Getopt::Long qw(:config no_auto_abbrev);
+use File::Basename qw(basename dirname);
+use Cwd qw(abs_path);
+
+my $P = basename($0);
+
+my $email_maintainer = 1;
+my $email_reviewer = 1;
+my $email_list = 1;
+my $output_roles = 0;
+my $output_rolestats = 0;
+my $output_separator;
+my $output_multiline = 1;
+my $do_keywords = 1;
+my $from_filename = 0;
+my $maintainer_path;
+my $self_test;
+my $show_help = 0;
+
+# Accepted and ignored: this implementation never mines git history,
+# so the git options (and the informational ones below) are no-ops.
+my %ignored;
+
+if (!GetOptions(
+	'm!' => \$email_maintainer,
+	'r!' => \$email_reviewer,
+	'l!' => \$email_list,
+	'roles!' => \$output_roles,
+	'rolestats!' => \$output_rolestats,
+	'separator=s' => \$output_separator,
+	'multiline!' => \$output_multiline,
+	'remove-duplicates!' => \$ignored{remove_duplicates},
+	'f|file' => \$from_filename,
+	'mpath|maintainer-path=s' => \$maintainer_path,
+	'k|keywords!' => \$do_keywords,
+	'self-test:s' => \$self_test,
+	'help|h|?' => \$show_help,
+	'email!' => \$ignored{email},
+	'git!' => \$ignored{git},
+	'git-all-signature-types!' => \$ignored{git_all_signature_types},
+	'git-blame!' => \$ignored{git_blame},
+	'git-blame-signatures!' => \$ignored{git_blame_signatures},
+	'git-fallback!' => \$ignored{git_fallback},
+	'git-chief-penguins!' => \$ignored{git_chief_penguins},
+	'git-min-signatures=i' => \$ignored{git_min_signatures},
+	'git-max-maintainers=i' => \$ignored{git_max_maintainers},
+	'git-min-percent=i' => \$ignored{git_min_percent},
+	'git-since=s' => \$ignored{git_since},
+	'hg-since=s' => \$ignored{hg_since},
+	'mailmap!' => \$ignored{mailmap},
+	'n!' => \$ignored{n},
+	's!' => \$ignored{s},
+	'fixes!' => \$ignored{fixes},
+	'moderated!' => \$ignored{moderated},
+	'pattern-depth=i' => \$ignored{pattern_depth},
+	'fe|file-emails!' => \$ignored{file_emails},
+    )) {
+    die "usage: $P [options] patchfile\n";
+}
+
+if ($show_help) {
+    usage();
+    exit 0;
+}
+
+$output_roles = 1 if ($output_rolestats);
+$output_multiline = 0
+    if (defined $output_separator && $output_separator ne ", ");
+
+if (-t STDIN && !@ARGV && !defined $self_test) {
+    die "$P: missing patchfile or -f file - use --help if necessary\n";
+}
+
+my $topdir = find_toplevel();
+my $maint_file = $maintainer_path // "$topdir/MAINTAINERS";
+die "$P: MAINTAINER file not found '$maint_file'\n" if (!-f $maint_file);
+
+my @sections = read_maintainer_file($maint_file);
+
+if (defined $self_test) {
+    exit(self_test($maint_file, \@sections) ? 1 : 0);
+}
+
+my (@files, @content);
+if ($from_filename) {
+    # Accept absolute paths by trimming the tree prefix, like the kernel script
+    @files = map { my $f = $_; $f =~ s@^\Q$topdir\E/@@; $f } @ARGV;
+} elsif (@ARGV) {
+    foreach my $patch (@ARGV) {
+	open(my $fh, '<', $patch)
+	    or die "$P: Can't open $patch: $!\n";
+	push(@content, <$fh>);
+	close($fh);
+    }
+    @files = patch_files(\@content);
+} else {
+    @content = <STDIN>;
+    @files = patch_files(\@content);
+}
+
+# In -f mode with keyword matching, scan the named files themselves.
+if ($from_filename && $do_keywords) {
+    foreach my $file (@files) {
+	next if ($file =~ m@\bMAINTAINERS$@);
+	my $path = $file =~ m@^/@ ? $file : "$topdir/$file";
+	next if (!-f $path);
+	open(my $fh, '<', $path) or next;
+	push(@content, <$fh>);
+	close($fh);
+    }
+}
+
+my @matches = match_sections(\@sections, \@files, \@content);
+
+my @out;
+my %seen;
+foreach my $m (@matches) {
+    my ($section, $type, $addr) = @$m;
+    next if ($type eq 'M' && !$email_maintainer);
+    next if ($type eq 'R' && !$email_reviewer);
+    next if ($type eq 'L' && !$email_list);
+    my $key = $addr =~ /<([^>]+)>/ ? $1 : $addr;
+    next if ($seen{$key}++);
+    if ($output_roles) {
+	my $role = $type eq 'M' ? maintainer_role($section->{S})
+	    : $type eq 'R' ? 'reviewer'
+	    : 'open list';
+	$addr .= " ($role:$section->{name})";
+    }
+    push(@out, $addr);
+}
+
+if ($output_multiline) {
+    print "$_\n" foreach (@out);
+} elsif (@out) {
+    print join($output_separator // ", ", @out) . "\n";
+}
+
+exit 0;
+
+sub usage {
+    print <<EOT;
+usage: $P [options] patchfile
+       $P [options] -f file...
+       $P --self-test
+
+Print the MAINTAINERS entries (maintainers, reviewers, lists) for the
+files changed by a patch.  With no patchfile argument, the patch is
+read from standard input.
+
+  --m, --r, --l	    include maintainers, reviewers, lists
+		    (prefix with "no" to exclude, e.g. --nom)
+  --roles	    show roles
+  --rolestats	    show roles (no statistics in this implementation)
+  --separator=X	    join addresses with X instead of newlines
+  -f, --file	    arguments are file names, not patches
+  --mpath=PATH	    use PATH as the MAINTAINERS file
+  -k, --keywords    match K: content patterns (default)
+  --self-test	    validate the MAINTAINERS file
+
+The --git* options are accepted for compatibility with the kernel
+scripts/get_maintainer.pl and b4, but ignored: this implementation
+only matches MAINTAINERS patterns, it never mines git history.
+EOT
+}
+
+sub find_toplevel {
+    # The tree top is always the parent of the directory holding this
+    # script, never the git checkout containing the current directory.
+    return abs_path(dirname(abs_path($0)) . '/..');
+}
+
+sub read_maintainer_file {
+    my ($file) = @_;
+
+    open(my $maint, '<', $file)
+	or die "$P: Can't open MAINTAINERS file '$file': $!\n";
+    my @sections;
+    my $cur;
+    while (<$maint>) {
+	chomp;
+	if (/^([A-Z]):\s*(.*)/) {
+	    my ($type, $raw) = ($1, $2);
+	    my $value = $raw;
+	    next if (!defined $cur);
+	    # The first field line promotes a pending header to a real
+	    # section, so preamble text never becomes a section.
+	    if (!$cur->{_kept}++) {
+		push(@sections, $cur);
+	    }
+	    if ($type eq 'F' || $type eq 'X') {
+		$value =~ s@\.@\\.@g;	## Convert . to \.
+		$value =~ s/\*/.*/g;	## Convert * to .*
+		$value =~ s/\?/./g;	## Convert ? to .
+		# A pattern naming a real directory matches everything below it
+		if ($raw !~ m@/$@ && -d "$topdir/$raw") {
+		    $value .= '/';
+		}
+	    }
+	    if ($type eq 'S') {
+		$cur->{S} = $value;
+	    } else {
+		push(@{$cur->{$type}}, $value);
+	    }
+	} elsif (!/^\s*$/ && !/^\s*#/) {
+	    $cur = { name => $_, S => 'Maintained', _kept => 0 };
+	}
+    }
+    close($maint);
+    return @sections;
+}
+
+sub patch_files {
+    my ($lines) = @_;
+    my @files;
+    foreach (@$lines) {
+	if (/^diff --git a\/(\S+) b\/(\S+)\s*$/) {
+	    push(@files, $1, $2);
+	} elsif (/^rename (?:from|to) (\S+)\s*$/) {
+	    push(@files, $1);
+	} elsif (/^ mode change [0-7]+ => [0-7]+ (\S+)\s*$/) {
+	    push(@files, $1);
+	} elsif (/^\+\+\+\s+(\S+)/ || /^---\s+(\S+)/) {
+	    my $filename = $1;
+	    next if ($filename eq '/dev/null');
+	    $filename =~ s@^[^/]*/@@;
+	    push(@files, $filename);
+	}
+    }
+    return @files;
+}
+
+# Same matching rules as the kernel file_match_pattern(): a pattern with
+# a trailing slash is a directory prefix; anything else must match from
+# the start with the same number of path components.
+sub file_match_pattern {
+    my ($file, $pattern) = @_;
+    if (substr($pattern, -1) eq '/') {
+	return 1 if ($file =~ m@^$pattern@);
+    } else {
+	if ($file =~ m@^$pattern@) {
+	    my $s1 = ($file =~ tr@/@/@);
+	    my $s2 = ($pattern =~ tr@/@/@);
+	    return 1 if ($s1 == $s2);
+	}
+    }
+    return 0;
+}
+
+sub match_sections {
+    my ($sections, $files, $content) = @_;
+    my (@matches, %added);
+    foreach my $file (@$files) {
+	foreach my $section (@$sections) {
+	    my $matched = 0;
+	    if (grep { file_match_pattern($file, $_) } @{$section->{X} // []}) {
+		next;
+	    }
+	    $matched = 1
+		if (grep { file_match_pattern($file, $_) } @{$section->{F} // []});
+	    if (!$matched) {
+		foreach my $re (@{$section->{N} // []}) {
+		    if ($file =~ m/$re/) {
+			$matched = 1;
+			last;
+		    }
+		}
+	    }
+	    if ($matched && !$added{$section->{name}}++) {
+		push_section_addrs(\@matches, $section);
+	    }
+	}
+    }
+    if ($do_keywords) {
+	foreach my $section (@$sections) {
+	    next if ($added{$section->{name}});
+	    next if (!@{$section->{K} // []});
+	    foreach my $line (@$content) {
+		foreach my $re (@{$section->{K}}) {
+		    if ($line =~ m/$re/) {
+			push_section_addrs(\@matches, $section);
+			$added{$section->{name}} = 1;
+			last;
+		    }
+		}
+		last if ($added{$section->{name}});
+	    }
+	}
+    }
+    return @matches;
+}
+
+sub push_section_addrs {
+    my ($matches, $section) = @_;
+    foreach my $type (qw(M R L)) {
+	foreach my $addr (@{$section->{$type} // []}) {
+	    push(@$matches, [$section, $type, $addr]);
+	}
+    }
+}
+
+sub maintainer_role {
+    my ($status) = @_;
+    my $role = lc($status // '');
+    return 'supporter' if ($role eq 'supported');
+    return 'maintainer' if ($role eq 'maintained');
+    return 'odd fixer' if ($role eq 'odd fixes');
+    return 'orphan minder' if ($role eq 'orphan');
+    return 'obsolete minder' if ($role eq 'obsolete');
+    return 'chief penguin' if ($role eq 'buried alive in reporters');
+    return $role ne '' ? $role : 'maintainer';
+}
+
+sub self_test {
+    my ($file, $sections) = @_;
+    my $errors = 0;
+    foreach my $section (@$sections) {
+	my $has_addr = (@{$section->{M} // []} ||
+			@{$section->{R} // []} ||
+			@{$section->{L} // []});
+	if (!$has_addr && $section->{S} !~ /orphan|obsolete/i) {
+	    print "$file: section without email address: $section->{name}\n";
+	    $errors++;
+	}
+	if (!@{$section->{F} // []} && !@{$section->{N} // []} &&
+	    !@{$section->{K} // []}) {
+	    print "$file: section without file match: $section->{name}\n";
+	    $errors++;
+	}
+    }
+    if (!$errors) {
+	print "$file: self-test passed (" . scalar(@$sections) .
+	    " section(s))\n";
+    }
+    return $errors;
+}
diff --git a/tests/Makefile.am b/tests/Makefile.am
index a199ce073c84..851b88acb3df 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -11,5 +11,5 @@ SUBDIRS = nsm_client
 
 MAINTAINERCLEANFILES = Makefile.in
 
-TESTS = t0001-statd-basic-mon-unmon.sh
+TESTS = t0001-statd-basic-mon-unmon.sh t0003-get-maintainer.sh
 EXTRA_DIST = test-lib.sh $(TESTS)
diff --git a/tests/t0003-get-maintainer.sh b/tests/t0003-get-maintainer.sh
new file mode 100755
index 000000000000..ead13861f840
--- /dev/null
+++ b/tests/t0003-get-maintainer.sh
@@ -0,0 +1,140 @@
+#!/bin/bash
+#
+# t0003-get-maintainer.sh -- check scripts/get_maintainer.pl
+#
+# Copyright (C) 2026  Jeff Layton <jlayton@kernel.org>
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License
+# as published by the Free Software Foundation; either version 2
+# of the License, or (at your option) any later version.
+#
+
+command -v perl >/dev/null 2>&1 || {
+	echo "SKIP: perl is not installed"
+	exit 77
+}
+
+BASEDIR=`dirname "$0"`
+TOPDIR=`realpath "$BASEDIR/.."`
+GETMAINT="$TOPDIR/scripts/get_maintainer.pl"
+
+[ -x "$GETMAINT" ] || {
+	echo "SKIP: $GETMAINT is not executable"
+	exit 77
+}
+
+# The exact flag sets b4 prep --auto-to-cc uses for To: and Cc:
+TO_FLAGS="--nogit --nogit-fallback --nogit-chief-penguins --norolestats --nol"
+CC_FLAGS="--nogit --nogit-fallback --nogit-chief-penguins --norolestats --nom"
+
+# A synthetic patch touching a nested file and a top-level file
+PATCH=`mktemp`
+trap "rm -f $PATCH" EXIT
+cat > "$PATCH" <<'EOF'
+diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
+--- a/utils/mountd/mountd.c
++++ b/utils/mountd/mountd.c
+@@ -1 +1 @@
+-old();
++new();
+diff --git a/README b/README
+--- a/README
++++ b/README
+@@ -1 +1 @@
+-old
++new
+EOF
+
+TCOUNT=0
+TPASS=0
+
+check() {
+	local name="$1"; shift
+	TCOUNT=$((TCOUNT + 1))
+	if "$@" >/dev/null 2>&1; then
+		echo "PASS $name"
+		TPASS=$((TPASS + 1))
+	else
+		echo "FAIL $name"
+	fi
+}
+
+to_lists_maintainer() {
+	$GETMAINT $TO_FLAGS < "$PATCH" | grep -q steved@redhat.com
+}
+
+to_excludes_list() {
+	! $GETMAINT $TO_FLAGS < "$PATCH" | grep -q vger.kernel.org
+}
+
+cc_lists_list() {
+	$GETMAINT $CC_FLAGS < "$PATCH" | grep -q linux-nfs@vger.kernel.org
+}
+
+cc_excludes_maintainer() {
+	! $GETMAINT $CC_FLAGS < "$PATCH" | grep -q steved@redhat.com
+}
+
+default_lists_both() {
+	[ $($GETMAINT < "$PATCH" | wc -l) -eq 2 ]
+}
+
+file_top_level() {
+	$GETMAINT -f README | grep -q steved@redhat.com
+}
+
+file_nested() {
+	$GETMAINT -f utils/mountd/mountd.c | grep -q steved@redhat.com
+}
+
+file_absolute() {
+	$GETMAINT -f "$TOPDIR/utils/mountd/mountd.c" | grep -q steved@redhat.com
+}
+
+default_has_no_roles() {
+	! $GETMAINT < "$PATCH" | grep -q ' (maintainer:\|(reviewer:\|(open list:'
+}
+
+roles_flag_shows_roles() {
+	$GETMAINT --roles < "$PATCH" | grep -q '(maintainer:NFS-UTILS)' &&
+	$GETMAINT --roles < "$PATCH" | grep -q '(open list:NFS-UTILS)'
+}
+
+# The MAINTAINERS file must come from the script's own tree, not from
+# whatever git checkout happens to contain the current directory.
+cwd_independent() {
+	command -v git >/dev/null 2>&1 || return 0
+	local faked
+	faked=`mktemp -d` || return 1
+	(cd "$faked" && git init -q 2>/dev/null && cat > MAINTAINERS <<'EOF'
+FAKE
+M:	Fake Person <fake-maintainer@example.com>
+S:	Maintained
+F:	*
+F:	*/
+EOF
+	) || { rm -rf "$faked"; return 1; }
+	(cd "$faked" && "$GETMAINT" -f README >"$faked.out" 2>&1)
+	local rc=$?
+	grep -q steved@redhat.com "$faked.out" && ! grep -q fake-maintainer@example.com "$faked.out"
+	rc=$?
+	rm -rf "$faked" "$faked.out"
+	return $rc
+}
+
+check self-test $GETMAINT --self-test
+check b4-To-lists-maintainer to_lists_maintainer
+check b4-To-excludes-list to_excludes_list
+check b4-Cc-lists-list cc_lists_list
+check b4-Cc-excludes-maintainer cc_excludes_maintainer
+check default-lists-both default_lists_both
+check default-has-no-roles default_has_no_roles
+check roles-flag-shows-roles roles_flag_shows_roles
+check file-top-level file_top_level
+check file-nested file_nested
+check file-absolute file_absolute
+check cwd-independent cwd_independent
+
+echo "$TPASS/$TCOUNT tests passed"
+[ "$TPASS" -eq "$TCOUNT" ]

-- 
2.56.0

